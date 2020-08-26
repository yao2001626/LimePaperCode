set terminal postscript eps
set output "measurements/Erlang.threadring.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Erlang.threadring.heavythread.data" using 1:2:3 axes x1y1 title "avg_example" with yerrorbars
