/* Compile and run under Linux and macOS with "javac pingpong.java; java Start"

Java monitors with signalling by notify and wait are used. Classes Ping and Pong
define active objects in the sense that they have methods that can be called and
each has a thread that calls methods of other objects. The thread and the
methods of each object are synchronized, i.e. run mutually exclusive. Two
objects are created: the Ping object calls the Pong object and passes itself as
a parameter, the Pong object asynchronously calls back the Ping object. The
number of bounces of the "ball" is passed along as well.

In Java, a program terminates when all threads terminate. The Ping and Pong
threads terminte when the number of bounces reaches 0 and 1, respectively.
*/
class Ping extends Thread {
  private Pong other;
  private int bounces = 0;
  Ping(Pong o, int b) {
    other = o; bounces = b;
  }
  synchronized void ping(int b) {
    bounces = b; notify();
  }
  synchronized public void run() {
    while (bounces > 0) {
      other.pong(this, bounces - 1);
      try {wait();} catch (InterruptedException e) {}
    }
  }
}
class Pong extends Thread {
  private Ping other;
  private int bounces;
  synchronized void pong(Ping o, int b) {
    other = o; bounces = b; notify();
  }
  synchronized public void run() {
    do {
      try {wait();} catch (InterruptedException e) {}
      other.ping(bounces - 1);
    } while (bounces > 1);
  }
}
class PingPong  {
  //static final int Rounds = 100000;
  public static void main(String args[]) {
    if(args.length < 1){
        System.err.println("Usage: java PingPong Rounds\n");
        return;
    }
    int Rounds = Integer.parseInt(args[0]);
    Pong pong = new Pong();
    Ping ping = new Ping(pong, Rounds);
    pong.start(); ping.start();
  }
}
