set terminal postscript eps
set output "measurements/Java.pingpong.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Java.pingpong.heavythread.data" using 1:2:3 axes x1y1 title "avg-95-CI" with yerrorbars
