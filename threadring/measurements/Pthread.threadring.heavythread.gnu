set terminal postscript eps
set output "measurements/Pthread.threadring.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Pthread.threadring.heavythread.data" using 1:2:3 axes x1y1 title "min-arg-max" with yerrorbars
