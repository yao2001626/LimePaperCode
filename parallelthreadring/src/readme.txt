ParallelThreadRing Benchmark

The ParallelThreadRing problem is used in
https://github.com/berkus/theron/tree/master/Benchmarks/ParallelThreadRing to
illustrate actors in the Theron C++ actor library: nodes are arranged in a ring
and a number of tokens are repeatedly forwarded from one node to the next one.
The token is an integer value that is decremented with every hop until it
reaches 0. The program terminates when all tokens are 0.

Like with the ThreadRing benchmark, there is a large number of processes,
significantly larger than the number of processor cores. Unlike with the
ThreadRing benchmark, where only one process can be active at any time, a large
number of processes can be ready, more than there are processor cores. Thus this
benchmark evaluates the efficiency of context-switching and allocating a
processor cores to ready processes.

The constants used in the implementations are:
- Hops: the number of hops the token takes
- Nodes: the number of nodes in the ring
- Tokens: the number of tokens initially in the ring
