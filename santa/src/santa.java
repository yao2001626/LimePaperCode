enum R {Relaxing, Back, Harnessing, Harnessed, Pulling, Done}
enum E {Working, Puzzled, Entering, Entered, Consulting, Enlightened}
enum Task {deliver, help}
class SantasShop {
    int rc = 9, ec = 3; // reindeer count, elf count
    R rs = R.Relaxing;  // state of reindeer
    E es = E.Working;   // state of elves

    synchronized void back() /* called by reindeer */ {
        while (rs != R.Relaxing) try {wait();} catch (Exception x) {}
        rc -= 1; if (rc == 0) {rs = R.Back; rc = 9;} notifyAll();
    }
    synchronized void harness() /* called by reindeer */ {
        while (rs != R.Harnessing) try {wait();} catch (Exception x) {}
        rc -= 1; if (rc == 0) {rs = R.Harnessed; rc = 9;} notifyAll();
    }
    synchronized void pull() /* called by reindeer */ {
        while (rs != R.Pulling) try {wait();} catch (Exception x) {}
        rc -= 1; if (rc == 0) {rs = R.Done; rc = 9;} notifyAll();
    }

    synchronized void puzzled() /* called by elves */ {
        while (es != E.Working) try {wait();} catch (Exception x) {}
        ec -= 1; if (ec == 0) {es = E.Puzzled; ec = 3;} notifyAll();
    }
    synchronized void enter() /* called by elves */ {
        while (es != E.Entering) try {wait();} catch (Exception x) {}
        es = E.Entered; notifyAll();
    }
    synchronized void consult() /* called by elves */ {
        while (es != E.Consulting) try {wait();} catch (Exception x) {}
        es = E.Enlightened; notifyAll();
    }

    synchronized Task wakeup() /* called by Santa */ {
        while (rs != R.Back && es != E.Puzzled) try {wait();} catch (Exception x) {}
        if (rs == R.Back) {rs = R. Harnessing; notifyAll(); return Task.deliver;}
        else {es = E.Entering; notifyAll(); return Task.help;}
    }
    synchronized void hitch() /* called by Santa */ {
        while (rs != R.Harnessed) try {wait();} catch (Exception x) {}
        rs = R.Pulling; notifyAll();
    }
    synchronized void ride() /* called by Santa */ {
        while (rs != R.Done) try {wait();} catch (Exception x) {}
        rs = R.Relaxing; notifyAll();
    }
    synchronized void welcome() /* called by Santa */ {
        while (es != E.Entered) try {wait();} catch (Exception x) {}
        es = E.Consulting; notifyAll();
    }
    synchronized void explain() /* called by Santa */ {
        while (es != E.Enlightened) try {wait();} catch (Exception x) {}
        ec -= 1; if (ec == 0) {es = E.Working; ec = 3;} else es = E.Entering;
        notifyAll();
    }

    public static void main(String[] args) {
        SantasShop shop = new SantasShop();
        new Santa(shop).start();
        for (int i = 0; i < 9; i++) new Reindeer(shop).start();
        for (int i = 0; i < 20; i++) {Thread e = new Elf(shop, i); e.setDaemon(true); e.start();}
    }
}
class Santa extends Thread {
    SantasShop shop;
    Santa(SantasShop ss) {shop = ss;}
    public void run() {
        for (int t = 0; t < 10000; t++) {
            Task task = shop.wakeup();
            if (task == Task.deliver) {
                shop.hitch(); shop.ride();
            } else {
                for (int i = 0; i < 3; i++) {shop.welcome(); shop.explain();}
            }
        }
    }
}
class Reindeer extends Thread {
    SantasShop shop;
    Reindeer(SantasShop ss) {shop = ss;}
    public void run() {
        for (int t = 0; t < 2000; t++) {shop.back(); shop.harness(); shop.pull();}
    }
}
class Elf extends Thread {
    SantasShop shop; int num;
    Elf(SantasShop ss, int n) {shop = ss; num = n;}
    public void run() {
        for (;;) {shop.puzzled(); shop.enter(); shop.consult();}
    }
}
