/* Compile and run under Linux and macOS with "go run parallelthreadring.go"

Synchronous channels are used for passing the token between the node goroutines.
Each node goroutine continuously accepts tokens; if the token is larger than 0,
it passes the token minus 1 on, otherwise it prints its id.

In Go, a program terminates when the main program terminates. Here, the main
program waits to receive a notificatiopn from the channel done; the node that
has the token with value 0 and prints it will notifies the main program through
the channel done.
*/
package main

const Hops = 10000
const Nodes = 1000
const Tokens = 999 // Tokens < Nodes
func node(n int, in chan int, out chan int, done chan bool) {
  for v := range in {
    if v > 0 {out <- v - 1
    } else {done <- true
    }
  }
}
func main() {
  done, ch0 := make(chan bool), make(chan int)
  ch := ch0
  for n := 1; n < Nodes; n++ {
    ch1 := make(chan int)
    go node(n, ch0, ch1, done)
    ch0 = ch1
  }
  go node(0, ch0, ch, done)
	for t := 0; t < Tokens; t++ {ch0 <- Hops}
  for t := 0; t < Tokens; t++ {<- done}
}
