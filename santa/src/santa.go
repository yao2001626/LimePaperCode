/* Compile and run under Linux and macOS with with:
"go run santa.go 1000"; optionally precede with
"export GOMAXPROCS=Threads".

Each node is a gorouting and that accepts input from two synchronous channels,
one for inserting and integer and one for querying with an integer. A query also
contains a channel over which the boolean result of the query is sent back.

In Go, a program terminates when the main program terminates. Here, the main
program first performs a round of insertions followed by a round of queries.
Thus at termination not all insertions might have finished.
*/
package main
import ("os"; "runtime"; "strconv")

var reindeerBack, reindeerHarness, reindeerPull chan bool
var back, harness, pull chan bool
var elfPuzzled, elfEnter, elfConsult chan bool
var puzzled, enter, consult chan bool
var done chan bool

func Santa(num int) {
  b, p := false, false // reindeer back, elves puzzled
  for t := 0; t < num; t++ { // invariant: !b
    if !p { // neither reindeer back nor elves puzzled
      select { // wait for either one
      case <-back: b = true
      case <-puzzled: p = true
      }
    }
    if p { // elves puzzled
      select { // check if reindeer back as well
      case <-back: b = true
      default:
      }
    }
    if b { // either b or p is true, prefer reindeer
      <-harness; <-pull; b = false
    } else { // otherwise elves
      for i := 0; i < 3; i++ {<-enter; <-consult}
      p = false
    }
  }
  done <- true
}
func Sleigh() {
  for {
    for i := 0; i < 9; i++ {<-reindeerBack}
    back <- true
    for i := 0; i < 9; i++ {<-reindeerHarness}
    harness <- true
    for i := 0; i < 9; i++ {<-reindeerPull}
    pull <- true
  }
}
func Shop() {
  for {
    for i := 0; i < 3; i++ {<-elfPuzzled}
    puzzled <- true
    for i := 0; i < 3; i++ {
      <-elfEnter; enter <- true
      <-elfConsult; consult <- true
    }
  }
}
func Reindeer() {
  for r := 0; r < 200000; r++ {
    reindeerBack <- true; reindeerHarness <- true; reindeerPull <- true
  }
}
func Elf() {
  for {
    elfPuzzled <- true; elfEnter <- true; elfConsult <- true
  }
}
func main() {
  num, _ := strconv.Atoi(os.Args[1])
  if len(os.Args) == 3 {
    thread_num, _ := strconv.Atoi(os.Args[2])
    runtime.GOMAXPROCS(thread_num)
  }
  reindeerBack, reindeerHarness, reindeerPull =
    make(chan bool), make(chan bool), make(chan bool)
  back, harness, pull = make(chan bool), make(chan bool), make(chan bool)
  elfPuzzled, elfEnter, elfConsult =
    make(chan bool), make(chan bool), make(chan bool)
  puzzled, enter, consult = make(chan bool), make(chan bool), make(chan bool)
  done = make(chan bool)
  go Santa(num); go Sleigh(); go Shop()
  for i := 0; i < 9; i++ {go Reindeer()}
  for i := 0; i < 20; i++ {go Elf()}
  <-done
}
