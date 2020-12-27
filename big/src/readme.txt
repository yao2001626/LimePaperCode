Big Benchmark

Big is a synthetic benchmark used in https://doi.org/10.1145/2364489.236449 and
https://doi.org/10.1145/2687357.2687368 for evaluating the performance of
many-to-many message passing among actors. The version used here is inspired by
https://www.diva-portal.org/smash/get/diva2:1043738/FULLTEXT02: initially, a
number of actors, called workers, are created. Workers are divided into
neighbourhoods and workers are aware only of workers in the same neighbourhood.
Workers are prepared to send a ping (ask a coworker for help) or receive a ping
(get asked for help). After sending a ping, the sender waits for a pong reply
from the recipient  (and potentially does some work while waiting) before
sending or receiving another ping. All workers ping a fixed number of rounds
then send done to the supervisor with the result of their work. Here, the result
is simply the number of sent pings minus the number of received pongs.

Each of the implementations has a procedure recipient() for each worker that
returns a pseudo-random number different from that of the worker's id. A ping
is sent to the worker with the generated id. All workers use a different seed
value but all implementations use the same random number algorithm with the
same seed values. A multiplicative linear congruential generator is used
following https://doi.org/10.1090/S0025-5718-99-00996-5. The value for m, the
modulus, is 2^16 - 15 and the value for a, the multiplier, is 32236. With these
values, all successive "random" values fit within 31 bits, i.e. are
representable as signed 32-bit integers.

The constants used in the implementations are:
- Workers: the number of workers in each neighbourhood
- Neighbourhoods: the number of neighbourhoods
- Rounds: the number of pings each worker sends
