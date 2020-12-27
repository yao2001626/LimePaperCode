/* Compile and run under Linux and macOS with "go run chameneos.go"

Synchronous channels are used for passing the token between the node goroutines.
The mall and each chameneos is a goroutine. The mall has a single channel over
which it receives requests from chameneos. Each chameneos sends to the mall its
own color and a channel over which it can receive the color of the partner.

In Go, a program terminates when the main program terminates. Here, the main
program waits on the channel done for the mall goroutine to signal that it is
terminating.
*/

package main
import "fmt"

const Chams = 100
const Rounds = 1000

type Color int
const (blue Color = 0; red; yellow)

type Request struct{col Color; reply chan Color}

func chameneos(col Color, mall chan Request) {
  reply := make(chan Color)
  for {
    // in forest
    mall <- Request{col, reply}
    // waiting to meet
    otherCol := <- reply
    // changing color
    if col != otherCol {col = 3 - col - otherCol}
  }
}
func mall(cham chan Request, done chan bool){
  diff := 0
  for r := 0; r < Chams * Rounds / 2; r++ {
    fst := <- cham; snd := <- cham
    fst.reply <- snd.col; snd.reply <- fst.col
    if fst.col != snd.col {diff += 1}
  }
  fmt.Println("Color changes:", diff)
  done <- true
}
func main() {
  req := make(chan Request); done := make(chan bool)
  go mall(req, done)
  for i := 0; i < Chams; i++ {go chameneos(Color(i % 3), req)}
  <- done
}
