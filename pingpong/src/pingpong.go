/* Compile and run under Linux and macOS with "go run pingpong.go"

Synchronous channels are used for sending the "ball" between the ping and the
pong goroutines. Messages from the ping goroutine to the pong goroutine include
the channel over which the pong goroutine sends the "ball" back.

In Go, a program terminates when the main program terminates. Here,the main
program waits for the goroutine ping to terminate, which is signalled through
the channel done.
*/
package main

import (
	"fmt"
	"os"
	"strconv"
)

type Request struct {
	pings   chan int
	bounces int
}

func ping(pongs chan Request, done chan int, Rounds int) {
	pings, bounces := make(chan int), Rounds
	for bounces > 0 {
		pongs <- Request{pings, bounces - 1}
		bounces = <-pings
	}
	done <- bounces
}
func pong(pongs chan Request) {
	for {
		r := <-pongs
		r.pings <- r.bounces - 1
	}
}
func main() {
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s Rounds\n", os.Args[0])
		return
	}
	ArgRounds := os.Args[1]
	Rounds, errR := strconv.Atoi(ArgRounds)
	if errR != nil {
		fmt.Println(errR)
		os.Exit(2)
	}
	pongs, done := make(chan Request), make(chan int)
	go ping(pongs, done, Rounds)
	go pong(pongs)
	<-done
	//fmt.Println(<- done)
}
