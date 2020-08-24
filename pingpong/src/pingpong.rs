/* Compile and under Linux and macOS with "rustc pingpong.rs; ./pingpong 1000"

Synchronous channels from the mpsc library (multiple producer, single consumer) are used for
sending the "ball" between the ping and the pong threads. Messages from the ping thread to the pong
thread include the channel over which the pong thread sends the "ball" back.

Rust requires all threads to terminate properly for the program to terminate properly. For this,
the pong thread terminates when the number of remaining bounces is 1 and the ping thread terminates
when it is 0. The main program waits for the ping thread to terminate.

Rust forces that the ping thread creates a new return channel in each iteration. Alternatively, the
return channel can be created once and then cloned, which can improve efficiency.
*/

use std::sync::mpsc::*;
use std::thread;
use std::env;

// static mul rounds: u32 = 1;

fn ping(pongs: SyncSender<(u32, SyncSender<u32>)>, rounds: u32) {
    let mut bounces = rounds;
    while bounces > 0 {
        let (tx, rx) = sync_channel(0);
        pongs.send((bounces - 1 , tx)).unwrap();
        bounces = rx.recv().unwrap();
    }
}
fn pong(pongs: Receiver<(u32, SyncSender<u32>)>) {
    loop {
        let (bounces, pings) = pongs.recv().unwrap();
        pings.send(bounces - 1).unwrap();
        if bounces == 1 {return;}
    }
}
fn main() {
    let args: Vec<String> = env::args().collect();
    let rounds: u32 = args[1].parse().unwrap();
    let (tx, rx) = sync_channel(0);
    let handle = thread::spawn(move || ping(tx, rounds));
    thread::spawn(move || pong(rx));
    handle.join().unwrap()
}