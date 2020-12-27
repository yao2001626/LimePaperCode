#Makefile for Parallel Thread Ring example
#author: Shucai Yao
#time: 2020.10.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/ParallelThreadRing_go bin/ParallelThreadRing_haskell bin/ParallelThreadRing_pthread  bin/ParallelThreadRing.beam bin/%.class 

bin/ParallelThreadRing_haskell: src/ParallelThreadRing.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/ParallelThreadRing_lime: src/ParallelThreadRing.lime
#	limec -o $@ $<

bin/ParallelThreadRing_go: src/ParallelThreadRing.go
	go build -o $@ $<

bin/ParallelThreadRing_pthread: src/ParallelThreadRing.c
	gcc -pthread -o $@ $<

#bin/ParallelThreadRing_rust: src/ParallelThreadRing.rs
#	rustc -o $@ $<

bin/ParallelThreadRing.beam: src/ParallelThreadRing.erl
	erlc -W -o bin $<
bin/%.class: src/ParallelThreadRing.java
	javac -d bin $<   
#bin/ParallelThreadRing_lime: src/ParallelThreadRing.lime
#	cd src && limec ParallelThreadRing.lime -o ../bin/ParallelThreadRing_lime
.PHONY: clean
	rm bin/ParallelThreadRing*   