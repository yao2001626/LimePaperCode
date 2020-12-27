package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
    "runtime"
    "strconv"
)

func link(left_input <-chan int, left_output chan<- int) {
    m := 0 // value of the node
    v := 0 // temp for receiving
    var right_output chan int
    var right_input chan int
    for {
        select {
        case v = <- left_input:
            if m == 0 {
                m = v
                right_output = make(chan int)
                right_input = make(chan int)
                go link(right_output, right_input)
            } else {
                if v < m {
                    right_output <- m
                    m = v
                } else {
                    right_output <- v
                }
            }
        case left_output <- m:
            m = <- right_input
        }
    }
}

func main() {
    if len(os.Args) != 4 {
        fmt.Printf("Usage: %s inputdata_dir num thread_num\n", os.Args[0])
        return
    }

    m := os.Args[1]
    num, err := strconv.Atoi(m)
    file_name := os.Args[2] + "/" + m
    file, err := os.Open(file_name)
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

    right_output := make(chan int)
    right_input := make(chan int)
    go link(right_output, right_input)
    for _, element := range input {
        //fmt.Println(index)
        right_output <- element
    }
    for i := 1; i <= num; i++ {
        <- right_input
        //fmt.Println( <- right_input)
        //fmt.Println(i)
    }
    //fmt.Printf("Done \n" )
    return
}
