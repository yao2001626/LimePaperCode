set terminal postscript eps
set output "measurements/Pthread_Mon.threadring.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Pthread_Mon.threadring.heavythread.data" using 1:2:3 axes x1y1 title "avg_example" with yerrorbars
