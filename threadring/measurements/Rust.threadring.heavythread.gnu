set terminal postscript eps
set output "measurements/Rust.threadring.heavythread.eps"
set xlabel ""
set ylabel ""
set title ""
plot "measurements/Rust.threadring.heavythread.data" using 1:2:3 axes x1y1 title "min-arg-max" with yerrorbars
