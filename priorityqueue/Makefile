#Makefile for Priority Queue example
#author: Shucai Yao
#time: 2020.10.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/PQ_go bin/PQ_haskell bin/PQ_pthread  bin/pq.beam bin/%.class 

bin/PQ_haskell: src/PQ.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/PQ_lime: src/PQ.lime
#	limec -o $@ $<

bin/PQ_go: src/PQ.go
	go build -o $@ $<

bin/PQ_pthread: src/PQ.c
	gcc -pthread -o $@ $<

#bin/PQ_rust: src/PQ.rs
#	rustc -o $@ $<

bin/pq.beam: src/pq.erl
	erlc -W -o bin $<
bin/%.class: src/PQ.java
	javac -d bin $<   
#bin/PQ_lime: src/PQ.lime
#	cd src && limec PQ.lime -o ../bin/PQ_lime
.PHONY: clean
	rm bin/PQ*   