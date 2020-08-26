set terminal postscript eps
set output "measurements/Java.threadring.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Java.threadring.heavythread.data" using 1:2:3 axes x1y1 title "avg_example" with yerrorbars
