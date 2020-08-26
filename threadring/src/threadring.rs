/* Compile under Linux and macOS with "rustc threadring.rs"; run with "./threadring".

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
use std::env;

// const HOPS: u32 = 100000; // HOPS must be greater than NODES ...
// const NODES: u32 = 1000;  // ... for proper termination

fn node(n: u32, tx: SyncSender<u32>, rx: Receiver<u32>, nodes: u32) {
  loop {
    let v = rx.recv().unwrap();
    if v > 0 {tx.send(v - 1).unwrap()
    } else {//println!("{}", n)
    }
    if v < nodes {break}
  }
}
fn main() {
  let args: Vec<String> = env::args().collect();
  let hops: u32= args[1].parse().unwrap();
  let nodes: u32 = args[2].parse().unwrap();
  let (tx0, mut rx0) = sync_channel(0);
  for n in 1 .. nodes {
    let (tx1, rx1) = sync_channel(0);
    spawn(move || node(n, tx1, rx0, nodes));
    rx0 = rx1
  }
  let tx = SyncSender::clone(&tx0);
  let handle = spawn(move || node(0, tx0, rx0, nodes));
  tx.send(hops).unwrap();
  handle.join().unwrap()
}
