# PingPong Benchmark

The PingPong problem is used in https://www.scala-lang.org/old/node/54 to
illustrate actors in Scala: a "ball" is repeatedly passed back and forth between
two actors. In https://doi.org/10.1145/2687357.2687368 the problem is part of a
suite of micro-benchmarks that evaluate specific implementation aspects of
actors. The number of actors is small and fixed, so there is no overhead of
creation, but only the actor with the ball can be active, so there is no
parallelism involved.

Here, we use it to evaluate the efficiency of synchronous communication. The
Ping player sends the "ball" and its own address to the Pong player, who sends
the "ball" back again to the received address. The number of remaining bounces
is decremented by both Ping and Pong. The program terminates when it reaches 0.

The constants used in the implementations are:
- Rounds: the number of bounces of the ball

# Result

![](ex_PingPong.png)
