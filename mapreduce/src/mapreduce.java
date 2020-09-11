/* Compile under Linux and macOS with "javac mapreduce.yield.java"; run with
"java MapReduce Num Rounds"

This version uses Java's built-in monitors with a single implict condition
variable as well as busy waiting and explicit yielding with Thread.yield().
Classes Reducer and Mapper define active objects in the sense that they have
methods that can be called and each has each object has its own thread. The
thread and the method of each object are synchronized, i.e. run mutually
exclusive. The methods of Reducer and Mapper wait on entry using the single
implict condition variable. The thread of each object waits on a boolean
condition in a loop, yielding on each iteration. The root node, i.e. the node
with the number 1, prints the result.

In Java, a program terminates when all (non-deamon) threads terminate. Here, the
mapper and reducer threads terminate when they receive a dedicated end-of-stream
value, -1.
*/
class Reducer extends Thread {
  int e1, e2, n;
  boolean a1, a2;
  Reducer next;
  Reducer(int n) {
    e1 = e2 = -1; this.n = n; a1 = a2 = false; next = null;
  }
  synchronized void reduce1(int x) {
    while (a1) try {wait();} catch (InterruptedException e) {}
    e1 = x; a1 = true;
  }
  synchronized void reduce2(int x) {
    while (a2) try {wait();} catch (InterruptedException e) {}
    e2 = x; a2 = true;
  }
  public void run() {
    while (true) {
      synchronized (this) {
        if (a1 && a2) {
          if (n <= 1) { // print only first time
            if (n == 1) {System.out.println(e1 + e2); n = 0;}
          } else {
            if (n % 2 == 0) next.reduce1(e1 + e2);
            else next.reduce2(e1 + e2);
          }
          if (e1 == 0) break;
          a1 = a2 = false; notifyAll();
        }
      }
      Thread.yield();
    }
  }
}
class Mapper extends Thread {
  int e, n;
  boolean a;
  Reducer next;
  Mapper(int n){
    e = -1; this.n = n; a = false; next = null;
  }
  synchronized void map(int x) {
    while (a) try {wait();} catch (InterruptedException e) {}
    e = x; a = true;
  }
  public void run() {
    while (true) {
      synchronized (this) {
        if (a) {
          if (n % 2 == 0) next.reduce1(e * e);
          else next.reduce2(e * e);
          if (e == 0) break;
          a = false; notify();
        }
      }
      Thread.yield();
    }
  }
}
class MapReduce {
  public static void main(String[] args) {
    int Num = Integer.parseInt(args[0]);
    int Rounds = Integer.parseInt(args[1]);
    long N = Num; // conversion to long required
    System.out.println(N * (N + 1) * (2 * N + 1) / 6);
    Mapper[] m = new Mapper[Num];
    Reducer[] r = new Reducer[Num];
    for (int i = 0; i < Num; i++) m[i] = new Mapper(i);
    for (int i = 1; i < Num; i++) r[i] = new Reducer(i);
    for (int i = 1; i < Num / 2; i++) {
      r[i * 2].next = r[i];
      r[i * 2 + 1].next = r[i];
    }
    for (int i = 0; i < Num; i++) {
      m[i].next = r[(i + Num) / 2];
    }
    for (int i = 0; i < Num; i++) m[i].start();
    for (int i = 1; i < Num; i++) r[i].start();
    for (int j = 0; j < Rounds; j++) {
      for(int i = 0; i < Num; i++) m[i].map(i + 1);
    }
    for (int i = 0; i < Num; i++) m[i].map(0);
  }
}
