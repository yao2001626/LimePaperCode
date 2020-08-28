set terminal postscript eps
set output "measurements/Erlang.threadring.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Erlang.threadring.lightthread.data" using 1:2:3 axes x1y1 title "min-arg-max" with yerrorbars
