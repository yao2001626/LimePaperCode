set terminal postscript eps
set output "measurements/Pthread.santa.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Pthread.santa.heavythread.data" using 1:2:3 axes x1y1 title "avg-95-CI" with yerrorbars
