set terminal postscript eps
set output "measurements/Haskell.mapreduce.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Haskell.mapreduce.lightthread.data" using 1:2 axes x1y1 title "95CI" with linespoint
