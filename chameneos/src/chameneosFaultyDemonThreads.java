/* Compile under Linux and macOS with "javac chameneos.java"; run with
"java Mall".

Java monitors with signalling by notify and wait are used. Classes Chameneos and
Mall define active objects in the sense that they have methods that can be
called and each has a thread that calls another objects: each chameneos calls
method arrive of the mall, passing a pointer to itself. The mall is monitor in
the sense that at any time only one chameneos can call the method arrive. When
that method is called by the second chameneos, the mall thread is notified using
the condition variable of an auxiliary object, mutate. The thread will then call
back the method meet of the two chameneos, passing the color of the other
chameneos. The chameneos can then change their color and go back to the forest.
The mall thread will also notify all further chameneos who got blocked at the
call of method arrive using the condition variable of the mall.

In Java, a program terminates when all non-demon threads terminate. Here, the
chameneos are demon threads and the mall is a non-demon thread.
*/

class Chameneos extends Thread {
	final int Blue = 0, Red = 1, Yellow = 2;
	int col;
	Mall mall;
	Chameneos(int c, Mall m) {
		col = c; mall = m; setDaemon(true);
	}
	synchronized void meet(int otherCol) {
		// changing color
		if (col != otherCol) col = 3 - col - otherCol;
		notify();
	}
	synchronized public void run() {
		while (true) {
			// in forest
	    mall.arrive(this, col);
	    // waiting to meet
			try {wait();} catch (InterruptedException e) {}
		}
	}
}
class Mall extends Thread {
	static final int Chams = 6;
	static final int Rounds = 10;
	int chams;
	Chameneos fstCham, sndCham;
	int fstCol, sndCol;
	Object mutate = new Object();
	Mall() {
		start();
	}
	synchronized void arrive(Chameneos ch, int c) {
		while (chams == 2) {
			try {wait();} catch (InterruptedException e) {}
		}
		chams += 1;
		if (chams == 1) {fstCham = ch; fstCol = c;
		} else {
			sndCham = ch; sndCol = c;
			synchronized(mutate) {mutate.notify();}
		}
	}
  public void run() {
		int diff = 0;
		synchronized(mutate) {
			for (int r = 0; r < Chams * Rounds / 2; r++) {
				try {mutate.wait();} catch (InterruptedException e) {}
				synchronized(this) {
				  fstCham.meet(sndCol); sndCham.meet(fstCol);
				  if (fstCol != sndCol) diff += 1;
					chams = 0; notifyAll();
				}
			}
		  System.out.println("Color changes: " + diff);
		}
	}
	public static void main(String args[]) {
		Mall m = new Mall();
		for (int i = 0; i < Chams; i++) new Chameneos(i % 3, m).start();
	}
}
