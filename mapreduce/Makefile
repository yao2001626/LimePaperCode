#Makefile for mapreduce example
#author: Shucai yao
#time: 2020.08.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/mapreduce_go bin/mapreduce_haskell  bin/mapreduce_rust bin/mapreduce.beam bin/mapreduce_pthread bin/%.class

bin/mapreduce_haskell: src/mapreduce.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/mapreduce_lime: src/mapreduce.lime
#	limec -o $@ $<

bin/mapreduce_go: src/mapreduce.go
	go build -o $@ $<

bin/mapreduce_pthread: src/mapreduce.c
	gcc -pthread -o $@ $<

bin/mapreduce_rust: src/mapreduce.rs
	rustc -o $@ $<
    
bin/mapreduce.beam: src/mapreduce.erl
	erlc -W -o bin $<
    
bin/%.class: src/mapreduce.java
	javac -d bin $<
    
#bin/mapreduce_lime: src/mapreduce.lime
#	cd src && limec mapreduce.lime -o ../bin/mapreduce_lime

.PHONY: clean
	rm mapreduce*   
