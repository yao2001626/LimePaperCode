set terminal postscript eps
set output "measurements/Go.threadring.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Go.threadring.heavythread.data" using 1:2:3 axes x1y1 title "min-arg-max" with yerrorbars
