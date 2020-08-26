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
class Node extends Thread {
  Node next;
  int token = - 1;
  int n;
  int nodes; 
  Node(int n, int nn) {
    this.n = n; this.nodes = nn; start();
  }
  synchronized void pass(int t) {
    token = t; notify();
  }
  synchronized public void run() {
    if (token == - 1)
      try {wait();} catch (InterruptedException e) {}
    while (true) {
      // System.out.println(n + " received " + token);
      if (token > 0) next.pass(token - 1);
      else System.out.println(n);
      if (token < this.nodes) break;
      try {wait();} catch (InterruptedException e) {}
    }
  }
}
class ThreadRing {
  // static final int Hops = 100000;
  // static final int Nodes = 1000;
  public static void main(String args[]) {
    if(args.length < 2){
        System.err.println("Usage: java ThreadRing Hops Nodes\n");
        return;
    }
    int Hops = Integer.parseInt(args[0]);
    int Nodes = Integer.parseInt(args[1]);
    Node nd0 = new Node(0, Nodes);
    Node nd = nd0;
    for (int n = 1; n < Nodes; n++) {
      nd.next = new Node(n, Nodes); nd = nd.next;
    }
    nd.next = nd0;
    nd0.pass(Hops);
  }
}
