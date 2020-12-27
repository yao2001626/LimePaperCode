/* Run first "cargo install crossbeam"; "cargo new rust" creates a new project;
add crossbeam = "0.7.3" to Cargo.toml; file main.rs has to be in src. Compile
with "cargo build --release"; compile and run with "cargo run --release".

Synchronous channels from the crossbeam crate are used for workers sending and
receiving ping request as well as pong replies. Unlike the standard mpsc
library, the crossbeam crate supports a select construct that is used here in
workers to either send a request or receive a request, whatever is possible.

Once a worker is done sending the specified number of requests, it notifies the
supervisor that it is done but keeps accepting requests. The supervisor waits
to be notified from all workers and then terminates, which terminates the whole
program.
*/

/* This version uses atomic reference counters, which allow vectors of channels
to be allocated on the heap and shared among all workers. */

extern crate crossbeam;
use crossbeam::channel::*;
use std::thread::spawn;
use std::sync::Arc;

const WORKERS: usize = 100;
const NEIGHBOURHOODS: usize = 10;
const ROUNDS: usize = 1000;

fn worker(id: usize, pings: Arc<Vec<(Sender<usize>, Receiver<usize>)>>,
  pongs: Arc<Vec<(Sender<usize>, Receiver<usize>)>>, done: Arc<Sender<i32>>) {
  let mut rand = 12345 + id;
  let mut recipient = || {
    loop {
	  rand = (32236 * rand) % 65521; // 2^16 - 15
	  if rand % WORKERS != id {return rand % WORKERS;}
	}
  };
  let mut pingpong: i32 = 0;
  let mut r = 0;
  while r < ROUNDS {
	select! {
	  send(pings[recipient()].0, id) -> _ => {
		let recid = pongs[id].1.recv().unwrap();
		pingpong += 1; r += 1;
		assert_eq!(recid, id);
	  }
      recv(pings[id].1) -> other => {
		pongs[other.unwrap()].0.send(other.unwrap()).unwrap();
		pingpong -= 1;
	  }
    }
  }
  done.send(pingpong).unwrap();
  loop {
    let other = pings[id].1.recv().unwrap();
	pongs[other].0.send(other).unwrap();
  }
}
fn supervisor() {
  let (done_tx, done_rx) = bounded(0);
  let done_tx = Arc::new(done_tx);
  for _ in 0 .. NEIGHBOURHOODS {
    let mut pings = vec![];
    let mut pongs = vec![];
    for _ in 0 .. WORKERS {
	  pings.push(bounded(0)); pongs.push(bounded(0));
    }
	let pings = Arc::new(pings);
	let pongs = Arc::new(pongs);
	for w in 0 .. WORKERS {
	  let pi = Arc::clone(&pings);
	  let po = Arc::clone(&pongs);
	  let d =  Arc::clone(&done_tx);
      spawn(move || worker(w, pi, po, d));
    }
  }
  let mut min: i32 = 0;
  let mut max: i32 = 0;
  for _ in 0 .. WORKERS * NEIGHBOURHOODS {
	let pingpong = done_rx.recv().unwrap();
	if pingpong < min {
	  min = pingpong
	} else if pingpong > max {
	  max = pingpong
	}
  }
  println!("min, max: {} {}", min, max);
}
fn main() {
  supervisor();
}

/* This version clones the channels, such that each worker has its own copy. It
is simpler but slightly less efficient than the version using atomic reference
counters.
*/

/*
extern crate crossbeam;
use crossbeam::channel::*;
use std::thread::spawn;

const WORKERS: usize = 100;
const NEIGHBOURHOODS: usize = 10;
const ROUNDS: usize = 1000;

fn worker(id: usize, pings: Vec<(Sender<usize>, Receiver<usize>)>,
  pongs: Vec<(Sender<usize>, Receiver<usize>)>, done: Sender<i32>) {
  let mut rand = 12345 + id;
  let mut recipient = || {
    loop {
	  rand = (32236 * rand) % 65521; // 2^16 - 15
	  if rand % WORKERS != id {return rand % WORKERS;}
	}
  };
  let mut pingpong: i32 = 0;
  let mut r = 0;
  while r < ROUNDS {
	select! {
	  send(pings[recipient()].0, id) -> _ => {
		let recid = pongs[id].1.recv().unwrap();
		pingpong += 1; r += 1;
		assert_eq!(recid, id);
	  }
      recv(pings[id].1) -> other => { //println!("{} received", id);
		pongs[other.unwrap()].0.send(other.unwrap()).unwrap();
		pingpong -= 1;
	  }
    }
  }
  done.send(pingpong).unwrap();
  loop {
    let other = pings[id].1.recv().unwrap();
	pongs[other].0.send(other).unwrap();
  }
}
fn supervisor() {
  let (done_tx, done_rx) = bounded(0);
  for _ in 0 .. NEIGHBOURHOODS {
    let mut pings = vec![];
    let mut pongs = vec![];
    for _ in 0 .. WORKERS {
	  pings.push(bounded(0)); pongs.push(bounded(0));
    }
	for w in 0 .. WORKERS {
	  let pi = pings.clone();
	  let po = pongs.clone();
	  let d =  done_tx.clone();
      spawn(move || worker(w, pi, po, d));
    }
  }
  let mut min: i32 = 0;
  let mut max: i32 = 0;
  for _ in 0 .. WORKERS * NEIGHBOURHOODS {
	let pingpong = done_rx.recv().unwrap();
	if pingpong < min {
	  min = pingpong
	} else if pingpong > max {
	  max = pingpong
	}
  }
  println!("min, max: {} {}", min, max);
}
fn main() {
  supervisor();
}
*/
