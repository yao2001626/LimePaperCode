
set terminal png
set output "ex_ThreadRing.png"
#set terminal postscript eps enhanced color font 'Helvetica,10'
#set output "ThreadRing.eps"
set multiplot layout 1,2 
set tmargin at screen 0.1
set bmargin at screen 0.80
set lmargin at screen 0.15
set rmargin at screen 0.55
set xlabel "Nodes"
set ylabel "Time (ms)"
set xrange [1000:9000]
set xtics rotate by -75 offset -1,0.5,0
set key left top
#set key vertical maxrows 4
#set xtics rotate by 0 offset 0,0,0

plot "measurements/Go.threadring.heavythread.data" using 1:2 title 'Go' with linespoints linecolor rgb "green" pointtype 39 pointsize 2, \
    "measurements/Erlang.threadring.heavythread.data" using 1:($2-1140) title 'Erlang' with linespoints linecolor rgb "blue" pointtype 10 pointsize 2, \
    "measurements/Java.threadring.heavythread.data" using 1:2 title 'Java' with linespoints linecolor rgb "coral" pointtype 70 pointsize 2, \
        "measurements/Pthread.threadring.heavythread.data" using 1:2 title 'Pthread' with linespoints linecolor rgb "#5F9EA0" pointtype 1 pointsize 2, \
    "measurements/Pthread_mon.threadring.heavythread.data" using 1:2 title 'PthreadMon' with linespoints linecolor rgb "cyan" pointtype 6 pointsize 2, \
    "measurements/Haskell.threadring.heavythread.data" using 1:2 title 'Haskell' with linespoints linecolor rgb "brown" pointtype 58 pointsize 2, \
    "measurements/Rust.threadring.heavythread.data" using 1:2 title 'Rust' with linespoints linecolor rgb 'gold' pointtype 50 pointsize 2         
set lmargin at screen 0.65
set rmargin at screen 0.95
set xlabel "Nodes"
#set ylabel "Time (ms)" offset 3,20,0
set xtics rotate by -75 offset -1,0.5,0
set xrange [100000:900000]
unset key

#set key left top
unset ylabel
plot "measurements/Go.threadring.lightthread.data" using 1:2 title 'Go' with linespoints linecolor rgb "green" pointtype 39 pointsize 2, \
     "measurements/Haskell.threadring.lightthread.data" using 1:2 title 'Haskell' with linespoints linecolor rgb "brown" pointtype 58 pointsize 2, \
     "measurements/Erlang.threadring.lightthread.data" using 1:($2-1140) title 'Erlang' with linespoints linecolor rgb "blue" pointtype 10 pointsize 2
unset multiplot
unset xtics
