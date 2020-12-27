import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
class LOT extends Thread {
    private int key, p;
    private boolean a;
    public LOT right, left; 
    
    LOT(int i) {
        setDaemon(true) ;
        this.key = i;
        this.p = 0;
        this.left = null;
        this.right = null;
        this.a = false;
    }
    
    public synchronized void add(int x) {
        while(this.a) {
            try{wait();} catch (InterruptedException e) {}
        }
        if(this.left != null) {
            this.a = true;
            this.p = x;
        }else if(x < this.key) {
            this.left = new LOT(x);
            this.left.start();
            this.right = new LOT(key);
            this.right.start();
            this.key = x;
        }else if(x > this.key) {
            this.left = new LOT(key);
            this.left.start();
            this.right = new LOT(x);
            this.right.start();
        }
    }
    
    public synchronized boolean has(int x) {
         while(this.a) {
            try{wait();} catch (InterruptedException e) {}
        }
        if(this.left == null) return x == this.key;
        else if(x <= this.key) return left.has(x);
        else return right.has(x);
    }
    

    private synchronized void doAdd(){
        if(this.a == true){
            if(this.p <= this.key){left.add(this.p);}
            else right.add(this.p);
            this.a = false;
            notifyAll();
        }
    }
    public void run() {
        while(true) {
            doAdd();
            Thread.yield();
        }
    }
    
    public static void main(String[] args){
        if(args.length < 2){
            System.err.println("Usage: java LOT num inputDir\n");
            return;
        }
        // repeat for 10 times to halve the overhead of JVM
        int jvm_repeat = 10;
        int i = 0;
        int num = Integer.parseInt(args[0]);
        int [] input = new int[num];
        try {
            Scanner scanner = new Scanner(new File(args[1],args[0]));
            while (scanner.hasNextLine()) {
                //System.out.println(scanner.nextLine());
                input[i] = Integer.parseInt(scanner.nextLine());
                i++;
            }
            scanner.close();
        } catch (FileNotFoundException e){
            e.printStackTrace();
        }
        while(jvm_repeat > 0) {
            LOT root = new LOT(5000);
            root.start();
            for(i = 0; i < num; i++) {
                //System.out.println("add: " +i);
                root.add(input[i]);
            }

            for(i = 0; i < num; i++) {
                //System.out.println("find: " +input[i]);
                int tmp = input[i];
                if(!root.has(tmp)) {
                    root.add(tmp);
                }
            }
            jvm_repeat--;
        }
        return;
    }
}