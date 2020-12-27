import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

class PQ extends Thread {
    private int m, p;
    private boolean a, r;
    private PQ next;
    private volatile boolean isRunning = true;
    PQ() {
        setDaemon(true); 
        this.m = 0;
        this.p = 0;
        this.a = false;
        this.r = false;
    }
    
    public synchronized boolean empty() {
        while(this.r) {
            try {
                wait();
            } 
            catch (InterruptedException e) {}
        }
        return this.next == null; 
    
    }
    
    public synchronized void add(int n) {
        while(this.a || this.r) {
            try {
                wait();
            }
            catch (InterruptedException e) {}
        }
        if (this.next == null) {
            this.m = n;
            this.next = new PQ();
            this.next.start();
        } else {
            this.p = n;
            this.a = true;
        }
        notifyAll();
    }
    
    public synchronized int remove() {
        while(this.a || this.r) {
            try{
                wait();
            }
            catch (InterruptedException e) {}
        }
        this.r = true;
        notifyAll();
        return this.m;
    }
    
    
    private synchronized void doAdd() {
        if(this.a) {
            if(this.m < this.p) {
                next.add(this.p);
            }else {
                next.add(this.m);
                this.m = this.p;
            }
            this.a = false;
            notifyAll();
        }
    }
    private synchronized void doRemove() {
        if(this.r) {
            if(this.next.empty()) {
                this.next = null;
            }
            else {
                this.m = this.next.remove();
            }
            this.r = false;
            notifyAll();
        }
    }
    
    public void run() {
        
        while(true) {
            doAdd();
            doRemove();
            //yield to the scheduler
            Thread.yield();
        }
    }
    
    /*public void kill() {
       isRunning = false;
    }*/
    public static void main(String[] args) {
        try {
            int i = 0;
            if(args.length < 2) {
                System.err.println("Usage: java -cp ./bin/PQ num inputdata_dir");
                return;
            }
            int jvmrepeat = 10;
            int num = Integer.parseInt(args[0]);
            int [] input = new int[num];
            Scanner scanner = new Scanner(new File(args[1], args[0]));
            while (scanner.hasNextLine()) {
                //System.out.println(scanner.nextLine());
                input[i] = Integer.parseInt(scanner.nextLine());
                i++;
            }
            scanner.close();
            while(jvmrepeat > 0){
                PQ head = new PQ();
                head.start();
                for (i = 0; i < num; i++) {
                    head.add(input[i]);
                }
                for (i = 0; i < num; i++) {
                    //System.out.println(head.remove());
                    head.remove();
                }
                jvmrepeat--;
            }

        } catch (FileNotFoundException e) {
            
            e.printStackTrace();
        }
        
    }
    
}
