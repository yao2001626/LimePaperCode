# Santa Claus Benchmark

The original description of the Santa Claus problem in
https://doi.org/10.1145/187387.187391 is:

"Santa Claus sleeps in his shop up at the North Pole, and can only be wakened by
either all nine reindeer being back from their year long vacation on a tropical
island, or by some elves who are having some difficulties making the toys. One
elf's problem is never serious enough to wake up Santa (otherwise, he may never
get any sleep), so, the elves visit Santa in a group of three. When three elves
are having their problems solved, any other elves wishing to visit Santa must
wait for those elves to return. If Santa wakes up to find three elves waiting at
his shop's door, along with the last reindeer having come back from the tropics,
Santa has decided that the elves can wait until after Christmas, because it is
more important to get his sleigh ready as soon as possible. (It is assumed that
the reindeer don't want to leave the tropics, and therefore they stay there
until the last possible moment.) The penalty for the last reindeer to arrive is
that it must get Santa while the others wait in a warming hut before being
harnessed to the sleigh."

Santa with 9 reindeer and 20 elves.  Santa’s division of work is that for 10,000
rounds until retirement, he rides the sleigh 2,000 times and helps 8,000 times
groups of three elves, or for 20 elves, each elf on average 1,200 times.  For
100,000 and 1,000,000 rounds until Santa’s retirement the ratio isthe same.

The parameters are:
- Num: Santa’s division of work
