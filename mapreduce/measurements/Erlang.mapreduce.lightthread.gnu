set terminal postscript eps
set output "measurements/Erlang.mapreduce.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Erlang.mapreduce.lightthread.data" using 1:2 axes x1y1 title "95CI" with linespoint
