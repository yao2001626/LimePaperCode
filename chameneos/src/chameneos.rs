/* Compile under Linux and macOS with "rustc chameneos.rs"; run with
"./chameneos".

Synchronous channels from the mpsc library (multiple producer, single consumer)
are used for chameneos notifying the mall of their arrival and for the mall
sending back the color of the other chameneos. Rust forces that each chameneos
creates a new reply channel in each iteration. Alternatively, the reply channel
can be created once and then cloned, which can improve efficiency.

Rust requires all threads to terminate properly for the program to terminate
properly. When the mall is done pairing chameneos, it replies to each further
request by sending None instead of a color, which will cause the requesting
chameneos to terminate.
*/

use std::sync::mpsc::*;
use std::thread::spawn;

const CHAMS: u32 = 100;
const MEETS: u32 = 1000;

type Color = u32; // BLUE = 0, RED = 1, YELLOW = 2

fn chameneos(mut col: Color,
    mall: SyncSender<(Color, SyncSender<Option<Color>>)>) {
    // let (tx, rx) = sync_channel(0); // alternative
    loop {
        // in forest
        // let tx1 = SyncSender::clone(&tx); // alternative
        // mall.send((col, tx1)).unwrap();   // alternative
        let (tx, rx) = sync_channel(0);
        mall.send((col, tx)).unwrap();
        // waiting to meet
        match rx.recv().unwrap() {
            None => return,
            Some(other_col) =>
                if col != other_col {col = 3 - col - other_col;}
        }
    }
}
fn mall(cham: Receiver<(Color, SyncSender<Option<Color>>)>, reps: u32){
  let mut diff = 0;
  for _ in 0 .. reps {
    let (fst_col, fst_reply) = cham.recv().unwrap();
    let (snd_col, snd_reply) = cham.recv().unwrap();
    fst_reply.send(Some(snd_col)).unwrap();
    snd_reply.send(Some(fst_col)).unwrap();
    if fst_col != snd_col {diff += 1}
  }
  println!("Color changes: {}", diff);
  for _ in 0 .. CHAMS {
      let (_col, reply) = cham.recv().unwrap();
      reply.send(None).unwrap();
  }
}

fn main() {
    let (tx, rx) = sync_channel(0);
    for i in 1 .. CHAMS {
        let tx1 = SyncSender::clone(&tx);
        spawn(move || chameneos(i % 3, tx1));
    }
    spawn(move || chameneos(0, tx));
    let handle = spawn(move || mall(rx, CHAMS * MEETS / 2));
    handle.join().unwrap()
}
