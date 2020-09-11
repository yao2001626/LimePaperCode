set terminal postscript eps
set output "measurements/Go.mapreduce.lightthread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Go.mapreduce.lightthread.data" using 1:2:3 axes x1y1 title "95CI" with yerrorbars
