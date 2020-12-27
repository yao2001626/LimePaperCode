/* This solution is deadlock-free, but differs from the Go solution.
The synchronization ensures that no two workers can ping one worker at the
same time. However, worker A can ping B, who would then pong A, while worker
C can ping A, so two threads can run in A simultaneously. Locking A either
before A pings B or when B pongs A does lead to deadlock.
*/

class Worker extends Thread {
  int id;
  Worker[] neighbours;
  Supervisor sup;
  int r; // random number
  int pingpong = 0;
  private int rnd() { // returns random neighbour different from id
    // linear congruential generator
    // using MINSTD, http://doi.org/10.1007/978-3-319-77697-2
    while (true) {
      r = (48271 * r) % 2147483647 ;// 2^31 - 1
      if (r < 0) r += 2147483647; // % in Java may be negative
      int result = r % Supervisor.Workers;
      if (result != id) return result;
    }
  }
  Worker (int id, Worker[] neighbours, Supervisor sup) {
    this.id = id; this.neighbours = neighbours;
    r = 12345 + id; // every worker has unique seed
    this.sup = sup;
  }
  synchronized void ping(Worker w, int id) {
    w.pong(id);
  }
  void pong(int id) {
    pingpong -= 1;
  }
  public void run() {
    for (int r = 0; r < Supervisor.Rounds; r++) {
      pingpong +=1;
      neighbours[rnd()].ping(this, id);}
    sup.done(pingpong);
  }
}
class Supervisor extends Thread {
  static final int Workers = 200; // number of workers
  static final int Neighbourhoods = 10;
  static final int Rounds = 10000; // how often each worker pings
  int min, max, replies;
  synchronized void done(int pingpong) {
    if (pingpong < min) min = pingpong;
    else if (pingpong > max) max = pingpong;
    replies += 1;
    // System.out.println("replies " + replies);
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
