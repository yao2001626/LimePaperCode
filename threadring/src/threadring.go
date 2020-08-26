/* Compile and run under Linux and macOS with "go run threadring.go"

Synchronous channels are used for passing the token between the node goroutines.
Each node goroutine continuously accepts tokens; if the token is larger than 0,
it passes the token minus 1 on, otherwise it prints its id.

In Go, a program terminates when the main program terminates. Here, the main
program waits to receive a notification from the channel done; the node that
has the token with value 0 and prints it notifies the main program through
the channel done.
*/
package main
import ("fmt"
        "os"
        "strconv")

// const Hops = 100000
// const Nodes = 1000
func node(n int, in chan int, out chan int, done chan bool) {
  for v := range in {
    if v > 0 {out <- v - 1
    } else {done <- true
    }
  }
}
func main() {
  if len(os.Args) != 3{
    fmt.Printf("Usage: %s Hops Nodes\n", os.Args[0])
    return
  }
  ArgHops := os.Args[1]
  ArgNodes := os.Args[2]
  Hops, errC := strconv.Atoi(ArgHops)
  if errC != nil {
    fmt.Println(errC)
    os.Exit(2)
  }  
  Nodes, errR := strconv.Atoi(ArgNodes)
  if errR != nil {
    fmt.Println(errR)
    os.Exit(2)
  }
  done, ch0 := make(chan bool), make(chan int)
  ch := ch0
  for n := 1; n < Nodes; n++ {
    ch1 := make(chan int)
    go node(n, ch0, ch1, done)
    ch0 = ch1
  }
  go node(0, ch0, ch, done)
	ch0 <- Hops; <- done
}
