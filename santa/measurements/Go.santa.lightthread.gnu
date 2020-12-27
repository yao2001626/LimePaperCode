set terminal postscript eps
set output "measurements/Go.santa.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Go.santa.lightthread.data" using 1:2:3 axes x1y1 title "avg-95-CI" with yerrorbars
