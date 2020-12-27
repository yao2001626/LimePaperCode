/* Compile under Linux and macOS with "rustc parallelthreadring.rs";
run with "./parallelthreadring".

Synchronous channels from the mpsc library (multiple producer, single consumer) are used for
passing the token between the node threads. Each thread continuously accepts tokens; if the token
is larger than 0, it passes the token minus 1 on, otherwise it prints its id. As each node owns the
transmitting and receiving ends of its channels, one transmitting end needs to be cloned for
sending the initial value of the token to a node thread.

Rust requires all threads to terminate properly for the program to terminate properly. For this,
each node thread terminates if it won't receive any more tokens, which is when the received token
is less than the number of nodes.
*/

use std::sync::mpsc::*;
use std::thread::spawn;

const HOPS: u32 = 10000;
const NODES: u32 = 1000;
const TOKENS: u32 = 999;
fn node(tx: SyncSender<u32>, rx: Receiver<u32>, done: SyncSender<()>) {
  loop {
    let v = rx.recv().unwrap();
    if v > 0 {tx.send(v - 1).unwrap();
    } else {done.send(()).unwrap();
    }
  }
}
fn main() {
  let (tx0, mut rx0) = sync_channel(0);
  let (txdone, rxdone) = sync_channel(0);
  for _ in 1 .. NODES {
    let (tx1, rx1) = sync_channel(0);
    let done = SyncSender::clone(&txdone);
    spawn(move || node(tx1, rx0, done));
    rx0 = rx1;
  }
  let tx = SyncSender::clone(&tx0);
  let done = SyncSender::clone(&txdone);
  spawn(move || node(tx0, rx0, done));
  for _ in 0 .. TOKENS {tx.send(HOPS).unwrap();}
  for _ in 0 .. TOKENS {rxdone.recv().unwrap();}
}
