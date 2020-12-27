package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
    "runtime"
    "strconv"
)

var found chan bool

func node(k int, parent chan int, find chan int) {
    key := k //find key of the node
    p := 0   // temp for receiving
    var leftchild_parent chan int
    var rightchild_parent chan int
    var leftchild_find chan int
    var rightchild_find chan int

    for {
        select {
        case p = <- parent:
            if leftchild_parent != nil {
                if p <= key {
                    leftchild_parent <- p
                } else {
                    rightchild_parent <- p
                }

            } else if p < key {
                leftchild_parent = make(chan int)
                leftchild_find = make(chan int)
                go node(p, leftchild_parent, leftchild_find)

                rightchild_parent = make(chan int)
                rightchild_find = make(chan int)
                go node(key, rightchild_parent, rightchild_find)
                key = p
            } else if p > key {
                leftchild_parent = make(chan int)
                leftchild_find = make(chan int)
                go node(key, leftchild_parent, leftchild_find)
                rightchild_parent = make(chan int)
                rightchild_find = make(chan int)
                go node(p, rightchild_parent, rightchild_find)
            }

        case p = <- find:
            if leftchild_parent == nil {
                found <- p == key
            } else if p <= key {
                leftchild_find <- p
            } else {
                rightchild_find <- p
            }
        }
    }
}

func main() {
    if len(os.Args) != 4 {
        fmt.Printf("Usage: %s num inputdata_dir thread_num\n", os.Args[0])
        return
    }
    m := os.Args[1]
    num, err := strconv.Atoi(m)
    if err != nil {
        log.Fatal(err)
    }
    dir := os.Args[2]
    filePath := dir + "/" + m
    file, err := os.Open(filePath)
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()
    var input []int
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        //fmt.Println(scanner.Text())
        tmp, err := strconv.Atoi(scanner.Text())
        if err != nil {
            log.Fatal(err)
        }
        input = append(input, tmp)
    }
    n := os.Args[3]
    if err != nil {
        fmt.Println(err)
        os.Exit(2)
    }
    thread_num, err := strconv.Atoi(n)
    runtime.GOMAXPROCS(thread_num)
    root := make(chan int)
    find := make(chan int)
    found = make(chan bool)
    go node(5000, root, find)

    for i := 0; i < num; i++ {
        root <- input[i]
    }
    for j := 0; j < num; j++ {
        find <- input[j]
        if !<- found {
            root <- input[j]
        }
    }
    //t1 := time.Now()
    //fmt.Printf("Go impl: %v\n", t1.Sub(t0))
}
