/* Compile under Linux and macOS with "javac chameneos.java"; run with
"java Mall".

Java monitors with signalling by notify and wait are used. Classes Chameneos and
Mall define active objects in the sense that they have methods that can be
called and each has a thread that calls another objects: each chameneos calls
method arrive of the mall, passing a pointer to itself. The mall is monitor in
the sense that at any time only one chameneos can call the method arrive. When
that method is called by the second chameneos, the mall thread is notified using
the implicit condition variable of the mall. The thread will then call back the
method meet of the two chameneos, passing the color of the other chameneos. The
chameneos can then change their color and go back to the forest. The mall thread
will also notify all further chameneos who got blocked at the call of method
arrive using the implicit condition variable of the mall. A single condition
variable is used, which means that when the second arriving chameneos notifies
the mall thread, all other waiting chameneos are notified as well.

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
		try {
			while (true) {
			  // in forest
	      mall.arrive(this, col);
	      // waiting to meet
			  wait();
			}
		} catch (InterruptedException e) {}
	}
}
class Mall extends Thread {
	static final int Chams = 100;
	static final int Rounds = 1000;
	Chameneos fstCham, sndCham; // invariant: sndCham != null ==> fstCham != null
	int fstCol, sndCol;
	Mall() {
		start();
	}
	synchronized void arrive(Chameneos ch, int c) throws InterruptedException {
		while (sndCham != null) wait();
		if (fstCham == null) {fstCham = ch; fstCol = c;
		} else {sndCham = ch; sndCol = c; notifyAll();
		}
	}
  synchronized public void run() {
		int diff = 0;
		for (int r = 0; r < Chams * Rounds / 2; r++) {
			while (sndCham == null)
				try {wait();} catch (InterruptedException e) {}
			fstCham.meet(sndCol); sndCham.meet(fstCol);
			if (fstCol != sndCol) diff += 1;
			fstCham = null; sndCham = null; notifyAll();
		}
		System.out.println("Color changes: " + diff);
	}
	public static void main(String args[]) {
		Mall m = new Mall();
		for (int i = 0; i < Chams; i++) new Chameneos(i % 3, m).start();
	}
}
