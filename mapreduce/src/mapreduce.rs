/* Compile under Linux and macOS with "rustc mapreduce.rs";
run with "./mapreduce Num Rounds".

Synchronous channels from the mpsc library (multiple producer, single consumer) are used for
passing the token between the node threads. A mapper thread takes a receiver and a sender as
parameters, a reducer thread takes two receivers and a sender as parameters. An auxiliary function
tree() constructs a tree with mappers as the leaves and reduces as the internal nodes; the
function returns a vector of channels to which the inputs to the mappers are sent. In the Go
version, all channels are stored in an array rather than created in tree(); storing the channels
in an array or vector cannot be done safely in Rust as the type system cannot check that the
receiver ends are used by only a single thread.

Rust requires all threads to terminate properly for the program to terminate properly. For this,
each mapper and reducer terminates when it receives a dedicted end-of-stream value, 0, after
passing that value on. The main program waits to receive the final end-of-stream value.
*/
use std::sync::mpsc::*;
use std::thread::spawn;
use std::env;
//const NUM: usize = 1024;
//const ROUNDS: u32 = 100;
fn mapper(rx: Receiver<usize>, tx: SyncSender<usize>) {
  loop {
    let v = rx.recv().unwrap();
    tx.send(v * v).unwrap();
    if v == 0 {break;}
  }
}
fn reducer(rx1: Receiver<usize>, rx2: Receiver<usize>, tx: SyncSender<usize>) {
  loop {
    let (v1, v2) = (rx1.recv().unwrap(), rx2.recv().unwrap());
    tx.send(v1 + v2).unwrap();
    if v1 == 0 {break;}
  }
}
fn tree(n: usize, tx: SyncSender<usize>, mut t: Vec<SyncSender<usize>>) -> Vec<SyncSender<usize>> {
  if n == 1 {
    let (tx1, rx1) = sync_channel(0);
    spawn(move || mapper(rx1, tx));
    t.push(tx1); t
  } else {
    let (tx1, rx1) = sync_channel(0);
    let (tx2, rx2) = sync_channel(0);
    spawn(move || reducer(rx1, rx2, tx));
    tree(n / 2, tx2, tree(n / 2, tx1, t))
  }
}
fn main() {
  let args: Vec<String> = env::args().collect();
  let num = args[1].parse::<usize>().unwrap();
  let rounds = args[2].parse::<u32>().unwrap();
  println!("{}", num * (num + 1) * (2 * num + 1) / 6);
  let (tx, rx) = sync_channel(0);
  let c = tree(num, tx, vec![]);
  spawn(move || {
    for _ in 0 .. rounds {
      for i in 0 .. num {c[i].send(i + 1).unwrap();}
    };
    for i in 0 .. num {c[i].send(0).unwrap();}
  });
  println!("{}", rx.recv().unwrap());
  for _ in 0 .. rounds {rx.recv().unwrap();}
}
