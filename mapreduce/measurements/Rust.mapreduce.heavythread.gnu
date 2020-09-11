set terminal postscript eps
set output "measurements/Rust.mapreduce.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Rust.mapreduce.heavythread.data" using 1:2:3 axes x1y1 title "95CI" with yerrorbars
