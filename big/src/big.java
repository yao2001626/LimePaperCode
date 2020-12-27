/* Compile under Linux and macOS with "javac big.java"; run with
"java Supervisor"

This implementation of the Big benchmark uses Java monitors. As calls in Java
are closed, i.e. the lock to a monitor is preserved while execution leaves the
monitor, a naive implementation with worker A calling ping of worker B who calls
back pong of worker A is prone to deadlock (nested monitor calls) if worker B
also pings worker A. Each ping-pong interaction involves exactly two workers.
The solution here is deadlock-free: the workers are ordered according to their
id and the worker initiating the ping-pong interaction first obtains a lock to
itself or to the recpient, whichever has the smaller id.

Once a worker thread is done with the specified number of requests, it
terminates. The supervisor waits to be notified from all workers and then
terminates as well.
*/
class Worker extends Thread {
  int id;
  Worker[] neighbours;
  Supervisor sup;
  int rand;
  int pingpong = 0;
  private int recipient() { // returns random neighbour different from id
    while (true) {
      rand = (32236 * rand) % 65521; // 2^16 - 15
      int result = rand % Supervisor.Workers;
      if (result != id) return result;
    }
  }
  Worker (int id, Worker[] neighbours, Supervisor sup) {
    this.id = id; this.neighbours = neighbours; this.sup = sup;
    rand = 12345 + id; // every worker has unique seed
  }
  synchronized void ping(Worker w, int id) {
    w.pong(id);
  }
  synchronized void pong(int id) {
    assert this.id == id : "received id incorrect";
    pingpong -= 1;
  }
  public void run() {
    for (int r = 0; r < Supervisor.Rounds; r++) {
      pingpong +=1;
      int n = recipient();
      if (n < id) { // first neighbours[n] is locked, then this is locked
        neighbours[n].ping(this, id);
      } else { // first this is locked, then neighbours[n] is locked
        synchronized(this) {neighbours[n].ping(this, id);}
      }
    }
    sup.done(pingpong);
  }
}
class Supervisor extends Thread {
  static final int Workers = 100;
  static final int Neighbourhoods = 10;
  static final int Rounds = 10000;
  int min, max, replies;
  synchronized void done(int pingpong) {
    if (pingpong < min) min = pingpong;
    else if (pingpong > max) max = pingpong;
    replies += 1;
    if (replies == Workers * Neighbourhoods) notify();
  }
  synchronized public void run() {
    for (int n = 0; n < Neighbourhoods; n++) {
      Worker[] neighbourhood = new Worker[Workers];
      for (int w = 0; w < Workers; w++) {
        neighbourhood[w] = new Worker(w, neighbourhood, this);
      }
      for (int w = 0; w < Workers; w++) {
        neighbourhood[w].start();
      }
    }
    try {wait();} catch (InterruptedException e) {}
    System.out.println("min, max: " + min + ", " + max);
  }
  public static void main(String args[]) {
    new Supervisor().start();
  }
}
