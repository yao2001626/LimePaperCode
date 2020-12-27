/* Compile and run under Linux and macOS with "go run big.go"

This implementation uses synchronous channels: each worker is a goroutine that
has channel ping for incoming requests and for outgoing requests as well as a
channel pong for outgoing replies and incoming replies.

Once a worker is done sending the specified number of requests, it notifies the
supervisor that it is done but keeps accepting requests. The supervisor waits
to be notified from all workers and then terminates as well.
*/
package main
import "fmt"

const Workers = 100
const Neighbourhoods = 10
const Rounds = 10000

func worker(id int, pings [Workers]chan int, pongs [Workers]chan int,
	done chan int) {
	rand := 12345 + id        // every worker has unique seed
	recipient := func() int { // generates random worker different from id
		for {
			rand = (32236 * rand) % 65521 // 2^16 - 15
			if rand % Workers != id {
				return rand % Workers
			}
		}
	}
	pingpong := 0
	r := 0 // number of rounds
	for r < Rounds {
		select {
		case pings[recipient()] <- id: // send ping to random neighbour
			recid := <-pongs[id]  // wait for pong to be returned
			pingpong++; r++
			if recid != id {panic("received id incorrect")}
		case other := <-pings[id]: // receive ping, send received id back again
			pongs[other] <- other
			pingpong--
		}
	}
	done <- pingpong // done with sending pings; still accepting incoming pings
	for {
		other := <-pings[id]
		pongs[other] <- other
	}
}
func supervisor() {
	done := make(chan int)
	for n := 0; n < Neighbourhoods; n++ {
		var pings, pongs [Workers]chan int
		for w := 0; w < Workers; w++ {
			pings[w], pongs[w] = make(chan int), make(chan int)
		}
		for w := 0; w < Workers; w++ {
			go worker(w, pings, pongs, done)
		}
	}
	min, max := 0, 0
	for w := 0; w < Workers * Neighbourhoods; w++ {
		pingpong := <-done
		if pingpong < min {
			min = pingpong
		} else if pingpong > max {
			max = pingpong
		}
	}
	fmt.Println("min, max:", min, max)
}
func main() {
	supervisor()
}
