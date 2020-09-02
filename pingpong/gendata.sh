./../gnuplotme --set x file $1.1.txt.dat 1 --set z avg 2 0 95 $1.*.txt.dat --plot x xaxis --plot z avg-95-CI --outfile $1
