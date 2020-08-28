set terminal postscript eps
set output "measurements/Go.pingpong.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Go.pingpong.lightthread.data" using 1:2:3 axes x1y1 title "min-arg-max" with yerrorbars
