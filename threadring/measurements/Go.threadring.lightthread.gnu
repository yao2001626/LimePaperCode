set terminal postscript eps
set output "measurements/Go.threadring.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Go.threadring.lightthread.data" using 1:2:3 axes x1y1 title "avg_example" with yerrorbars
