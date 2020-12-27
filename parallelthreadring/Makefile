#Makefile for Parallel Thread Ring example
#author: Shucai Yao
#time: 2020.10.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/ParallelThreadRing_go bin/ParallelThreadRing_haskell bin/ParallelThreadRing_pthread  bin/ParallelThreadRing.beam bin/%.class bin/ParallelThreadRing_rust

bin/ParallelThreadRing_haskell: src/parallelthreadring.hs
	$(GHC) $(FLAGS)  -o $@ $<

bin/ParallelThreadRing_go: src/parallelthreadring.go
	go build -o $@ $<

bin/ParallelThreadRing_pthread: src/parallelthreadring.sem.c
	gcc -pthread -o $@ $< -D Hops=10000 -D Nodes=1000 -D Tokens=100

bin/ParallelThreadRing_rust: src/parallelthreadring.rs
	rustc -o $@ $<

bin/ParallelThreadRing.beam: src/parallelthreadring.erl
	erlc -W -o bin $<

bin/%.class: src/parallelthreadring.java
	javac -d bin $<   

#bin/ParallelThreadRing_lime: src/ParallelThreadRing.lime
#	cd src && limec ParallelThreadRing.lime -o ../bin/ParallelThreadRing_lime

.PHONY: clean
	rm bin/ParallelThreadRing*  
	rm *.class 