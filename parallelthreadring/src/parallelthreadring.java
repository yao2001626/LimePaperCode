/* Compile under Linux and macOS with "javac threadring.java"; run with
"java ThreadRing"

Java monitors with signalling by notify and wait are used. Class Node defines
active objects in the sense that they have a method that can be called and each
has a thread that calls another object. The thread and the method of each object
are synchronized, i.e. run mutually exclusive. Each object passes the token by
calling the pass method of the next object. That method notifies the object's
thread to pass on the token to its next object. A token value of -1 is used by
the thread to check if a valid token has already been passed or the thread needs
to wait for it.

In Java, a program terminates when all threads terminate. Each node thread
terminates when it won't receive any more tokens, which is when the received
token is less than the number of nodes.
*/

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class Node extends Thread {
  final Lock lock = new ReentrantLock();
  final Condition empty = lock.newCondition();
  final Condition full = lock.newCondition();
  Node next;
  int token = - 1;
  int n;
  Counter c;
  Node(int n, Counter c) {
    this.n = n; this.c = c;
    setDaemon(true); start();
  }
  void pass(int t) {
    lock.lock();
    try {
      while (token >= 0) empty.await();
      token = t; full.signal();
    } catch (InterruptedException e) {
    } finally {lock.unlock();
    }
  }
  public void run() {
    lock.lock();
    try {
      while (true) {
        while (token == - 1) full.await();
        // System.out.println(n + " received " + token);
        if (token > 0) next.pass(token - 1);
        else c.dec();
        token = - 1; empty.signal();
      }
    } catch (InterruptedException e) {
    //} finally {lock.unlock();
    }
  }
}
class Counter {
  int count;
  Counter(int c) {count = c;}
  synchronized void dec() {count -= 1; if (count == 0) notify();}
  synchronized void zero() {
    if (count > 0)
      try {wait();} catch (InterruptedException e) {}
  }
}
class ParallelThreadRing {
  static final int Hops = 10000;
  static final int Nodes = 1000;
  static final int Tokens = 999;
  public static void main(String args[]) {
    Counter c = new Counter(Tokens);
    Node nd0 = new Node(0, c);
    Node nd = nd0;
    for (int n = 1; n < Nodes; n++) {
      nd.next = new Node(n, c); nd = nd.next;
    }
    nd.next = nd0;
    for (int t = 0; t < Tokens; t++) nd0.pass(Hops);
    c.zero();
  }
}
