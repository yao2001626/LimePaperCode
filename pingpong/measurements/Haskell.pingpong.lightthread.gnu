set terminal postscript eps
set output "measurements/Haskell.pingpong.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Haskell.pingpong.lightthread.data" using 1:2:3 axes x1y1 title "min-arg-max" with yerrorbars
