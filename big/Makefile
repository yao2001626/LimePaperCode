#Makefile for Big example
#Author: Shucai Yao
#Time: 2020.12.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/BIG_go bin/BIG_haskell bin/BIG_pthread  bin/BIG.beam bin/%.class 

bin/BIG_haskell: src/BIG.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/BIG_lime: src/BIG.lime
#	limec -o $@ $<

bin/BIG_go: src/BIG.go
	go build -o $@ $<

bin/BIG_pthread: src/BIG.c
	gcc -pthread -o $@ $<

#bin/BIG_rust: src/BIG.rs
#	rustc -o $@ $<

bin/BIG.beam: src/BIG.erl
	erlc -W -o bin $<
bin/%.class: src/BIG.java
	javac -d bin $<   
#bin/BIG_lime: src/BIG.lime
#	cd src && limec BIG.lime -o ../bin/BIG_lime
.PHONY: clean
	rm bin/BIG*   