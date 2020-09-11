/* Compile and run under Linux and macOS with with:
"go run mapreduce.go Num Rounds"; optionally precede with
"export GOMAXPROCS=Threads".

Synchronous channels are used for passing the token between the node goroutines.
Each node goroutine continuously accepts tokens; if the token is larger than 0,
it passes the token minus 1 on, otherwise it prints its id.

In Go, a program terminates when the main program terminates. Here, the main
program waits to receive a notificatiopn from the channel done; the node that
has the token with value 0 and prints it will notifies the main program through
the channel done.
*/
package main
import ("fmt"; "os"; "strconv")

func mapper(in chan int, out chan int) {
    for {v := <- in; out <- v * v}
}
func reducer(in1, in2 chan int, out chan int) {
  for {v1, v2 := <- in1, <- in2; out <- v1 + v2}
}
func main() {
  Num, _ := strconv.Atoi(os.Args[1])
  Rounds, _ := strconv.Atoi(os.Args[2])
  fmt.Println((Num * (Num + 1) * (2 * Num + 1)) / 6)
  r := make([]chan int, Num * 2)
  m := make([]chan int, Num)
  for i := range r {r[i] = make(chan int)}
  for i := range m {m[i] = make(chan int)}
  for i := 0; i < Num; i++ {go mapper(m[i], r[i + Num])}
  for i := 1; i < Num; i++ {go reducer(r[i * 2], r[i * 2 + 1], r[i])}
  go func() {
    for j := 0; j < Rounds; j++ {
      for i := 0; i < Num; i++ {m[i] <- i + 1}
    }
  }()
  fmt.Println(<- r[1])
  for j := 1; j < Rounds; j++ {<- r[1]}
}
