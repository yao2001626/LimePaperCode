# Chameneos Benchmark

The Chameneos concurrency game was proposed in
https://doi.org/10.1109/AICCSA.2003.1227495 (also at
https://cedric.cnam.fr/fichiers/RC474.pdf) for comparing programming styles
with Ada rendezvous, Java monitors, and C/Pthread semaphores. According to the
authors, chameneos are lizards from the Solu Khombu region. They eat honeysuckle
leaves, play pall mall, may have blue, yellow or red skin colour, with the
property while playing pall mall with a chameneos of a different colour to
change their skin colour as well as their partner’s one into the third possible
colour.

Here, we start with a fixed population of chameneos whose life follows a cyclic
patterns: chameneos live lonely in the forest eating honeysuckle leaves and
training. When a chameneos is ready for competition, it requests entry to the
mall to play pall mall with another chameneos. When two chameneos are ready,
they enter the mall and get to know the color of their partner. If the color is
different from the own color, they change their color to the third color. After
that, they leave the mall to go back to the forest. The main program prints the
number of color changes.

In computing terms, the mall is a server that arranges rendezvous of chameneos,
the clients. The communication structure is many-to-one, leading to contention
on the server.

The constants used in the implementations are:
1. Chams: the number of chameneos
2. Rounds: how ofter each chamenos competes at the mall
