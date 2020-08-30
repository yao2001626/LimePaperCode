
set terminal png
set output "ex_PingPong.png"
#set terminal postscript eps enhanced color font 'Helvetica,10'
#set output "PingPong.eps"
set multiplot layout 1,2 
set tmargin at screen 0.1
set bmargin at screen 0.80
set lmargin at screen 0.13
set rmargin at screen 0.60
set xlabel "Tokens"
set ylabel "Time (ms)"
set xrange [1000:9000]
set xtics rotate by -75 offset -1,0.5,0

set key left top
#set key height 1
#set key width 0.2
#set key font "Helvetica, 5"
set key vertical maxrows 4
#set key 0.15, 0.45, 0.1, 0.3 
#set xtics rotate by 0 offset 0,0,0

plot "measurements/Lime.pingpong.heavythread.data" using 1:2 title 'Lime' with linespoints linecolor rgb "red" pointtype 26 pointsize 2, \
    "measurements/Go.pingpong.heavythread.data" using 1:2 title 'Go' with linespoints linecolor rgb "green" pointtype 39 pointsize 2, \
    "measurements/Erlang.pingpong.heavythread.data" using 1:($2-1100) title 'Erlang' with linespoints linecolor rgb "blue" pointtype 10 pointsize 2, \
    "measurements/Java.pingpong.heavythread.data" using 1:2 title 'Java' with linespoints linecolor rgb "coral" pointtype 70 pointsize 2, \
    "measurements/Pthread.pingpong.heavythread.data" using 1:2 title 'Pthread' with linespoints linecolor rgb "#5F9EA0" pointtype 1 pointsize 2, \
    "measurements/Haskell.pingpong.heavythread.data" using 1:2 title 'Haskell' with linespoints linecolor rgb "brown" pointtype 58 pointsize 2, \
    "measurements/Rust.pingpong.heavythread.data" using 1:2 title 'Rust' with linespoints linecolor rgb 'gold' pointtype 50 pointsize 2        
set lmargin at screen 0.70
set rmargin at screen 0.99
set xlabel "Tokens"
#set ylabel "Time (ms)" offset 3,20,0
set xtics rotate by -75 offset -1,0.5,0
set xrange [100000:900000]
unset key
#set key left top
unset ylabel
plot "measurements/Lime.pingpong.lightthread.data" using 1:2 title 'Lime' with linespoints linecolor rgb "red" pointtype 26 pointsize 2, \
     "measurements/Go.pingpong.lightthread.data" using 1:2 title 'Go' with linespoints linecolor rgb "green" pointtype 39 pointsize 2, \
     "measurements/Erlang.pingpong.lightthread.data" using 1:($2-1100) title 'Erlang' with linespoints linecolor rgb "blue" pointtype 10 pointsize 2, \
     "measurements/Haskell.pingpong.lightthread.data" using 1:2 title 'Haskell' with linespoints linecolor rgb "brown" pointtype 58 pointsize 2
     #"../Results/tmp-dir/Rust.pingpong.lightthread.data" using 1:2 title 'Rust' with linespoints linecolor rgb "gold" pointtype 50 pointsize 2 
unset multiplot
unset xtics
