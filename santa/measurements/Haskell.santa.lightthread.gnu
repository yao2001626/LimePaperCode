set terminal postscript eps
set output "measurements/Haskell.santa.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Haskell.santa.lightthread.data" using 1:2 axes x1y1 title "avg-95-CI" with linespoint
