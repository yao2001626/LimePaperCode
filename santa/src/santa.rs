/* Run first "cargo install crossbeam"; "cargo new rust" creates a new project;
add crossbeam = "0.7.3" to Cargo.toml; file main.rs has to be in src. Compile
with "cargo build --release"; compile and run with "cargo run --release".

Synchronous channels from the crossbeam crate are used. Unlike the standard
mpsc library, the crossbeam crate supports a select construct that is used here
in nodes to either receiving the next integer or sending the smallest integer,
whatever is possible. Each node is a thread and synchronous channels are used:
- left_in for receiving a new integer from a user
- left_out for sending the smallest integer to a user
- right_out for sending an integer to the next node
- right_in for receiving the smallest integer from the next node or -1 if there
  there are no more integers.
The channel names have "tx" and "rx" appended for the transmitting and
receiving.

The main program terminates after first inserting and then removing the
generated sequence of integers. All nodes run until they don't have an integer
to hold, i.e. receive -1 from the successor node.
*/

extern crate crossbeam;
use crossbeam::channel::*;
use std::thread::spawn;
use std::env;

//const ROUNDS: u32 = 1000000;

fn santa(rounds: u32,
  back: Receiver<()>, harness: Receiver<()>, pull:Receiver <()>,
  puzzled: Receiver<()>, enter: Receiver<()>, consult: Receiver<()>) {
  let mut b = false;
  let mut p = false;
  for _ in 0 .. rounds {
    if !p {
      select! {
        recv(back) -> _ => {b = true;}
        recv(puzzled) -> _ => {p = true;}
      }
    }
    if p {
      select! {
        recv(back) -> _ => {b = true;}
        default() => {}
      }
    }
    if b {
      harness.recv().unwrap(); pull.recv().unwrap(); b = false;
    } else {
      for _ in 0 .. 3 {enter.recv().unwrap(); consult.recv().unwrap();}
      p = false
    }
  }
}
fn sleigh(back: Sender<()>, harness: Sender<()>, pull: Sender<()>,
  reindeer_back: Receiver<()>,reindeer_harness: Receiver<()>,
  reindeer_pull: Receiver<()>) {
  loop {
    for _ in 0 .. 9 {reindeer_back.recv().unwrap();}
    back.send(()).unwrap();
    for _ in 0 .. 9 {reindeer_harness.recv().unwrap();}
    harness.send(()).unwrap();
    for _ in 0 .. 9 {reindeer_pull.recv().unwrap();}
    pull.send(()).unwrap();
  }
}
fn shop(puzzled: Sender<()>, enter: Sender<()>, consult: Sender<()>,
  elf_puzzled: Receiver<()>, elf_enter: Receiver<()>, elf_consult: Receiver<()>) {
  loop {
    for _ in 0 .. 3 {elf_puzzled.recv().unwrap();}
    puzzled.send(()).unwrap();
    for _ in 0 .. 3 {
      elf_enter.recv().unwrap();
      enter.send(()).unwrap();
      elf_consult.recv().unwrap();
      consult.send(()).unwrap();
    }
  }
}
fn reindeer(rounds: u32, reindeer_back: Sender<()>,
  reindeer_harness: Sender<()>, reindeer_pull: Sender<()>) {
  for _ in 0 .. rounds {
    reindeer_back.send(()).unwrap();
    reindeer_harness.send(()).unwrap();
    reindeer_pull.send(()).unwrap();
  }
}
fn elf(elf_puzzled: Sender<()>, elf_enter: Sender<()>, elf_consult: Sender<()>) {
  loop {
    elf_puzzled.send(()).unwrap();
    elf_enter.send(()).unwrap();
    elf_consult.send(()).unwrap();
  }
}
fn main() {
  let args: Vec<String> = env::args().collect();
  let santarounds = args[1].parse::<u32>().unwrap();
  let (reindeer_back_tx, reindeer_back_rx) = bounded(0);
  let (reindeer_harness_tx, reindeer_harness_rx) = bounded(0);
  let (reindeer_pull_tx, reindeer_pull_rx) = bounded(0);
  let (back_tx, back_rx) = bounded(0);
  let (harness_tx, harness_rx) = bounded(0);
  let (pull_tx, pull_rx) = bounded(0);
  let (elf_puzzled_tx, elf_puzzled_rx) = bounded(0);
  let (elf_enter_tx, elf_enter_rx) = bounded(0);
  let (elf_consult_tx, elf_consult_rx) = bounded(0);
  let (puzzled_tx, puzzled_rx) = bounded(0);
  let (enter_tx, enter_rx) = bounded(0);
  let (consult_tx, consult_rx) = bounded(0);
  let handle = spawn(move || santa(santarounds, back_rx, harness_rx, pull_rx,
    puzzled_rx, enter_rx, consult_rx));
  spawn(move || sleigh(back_tx, harness_tx, pull_tx,
    reindeer_back_rx, reindeer_harness_rx, reindeer_pull_rx));
  spawn(move || shop(puzzled_tx, enter_tx, consult_tx,
    elf_puzzled_rx, elf_enter_rx, elf_consult_rx));
  for _ in 0 .. 9 {
    let b = reindeer_back_tx.clone();
    let h = reindeer_harness_tx.clone();
    let p = reindeer_pull_tx.clone();
    spawn(move || reindeer(santarounds / 5, b, h, p));
  }
  for _ in 0 .. 20 {
    let p = elf_puzzled_tx.clone();
    let e = elf_enter_tx.clone();
    let c = elf_consult_tx.clone();
    spawn(move || elf(p, e, c));
    // println!("{}", right_in_rx.recv().unwrap());
  }
  handle.join().unwrap()
}
