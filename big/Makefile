#Makefile for Big example
#Author: Shucai Yao
#Time: 2020.12.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/BIG_go  bin/BIG_pthread  bin/BIG.beam bin/%.class #bin/big_haskell

#bin/big_haskell: src/big.hs
#	$(GHC) $(FLAGS)  -o $@ $<

#bin/big_lime: src/big.lime
#	limec -o $@ $<

bin/BIG_go: src/big.go
	go build -o $@ $<

bin/BIG_pthread: src/big.c
	gcc -pthread -o $@ $<

#bin/BIG_rust: src/BIG.rs
#	rustc -o $@ $<

bin/BIG.beam: src/big.erl
	erlc -W -o bin $<

bin/%.class: src/big.java
	javac -d bin $<   

.PHONY: clean
	rm bin/BIG*   