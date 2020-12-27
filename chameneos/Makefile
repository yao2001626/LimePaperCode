#Makefile for Chameneos example
#author: Shucai Yao
#time: 2020.10.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/Chameneos_go bin/Chameneos_haskell bin/Chameneos_pthread  bin/Chameneos.beam bin/%.class 

bin/Chameneos_haskell: src/chameneos.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/Chameneos_lime: src/chameneos.lime
#	limec -o $@ $<

bin/Chameneos_go: src/chameneos.go
	go build -o $@ $<

bin/Chameneos_pthread: src/chameneos.c
	gcc -pthread -o $@ $<

bin/Chameneos_rust: src/chameneos.rs
	rustc -o $@ $<

bin/Chameneos.beam: src/chameneos.erl
	erlc -W -o bin $<

bin/%.class: src/chameneos.java
	javac -d bin $<   

.PHONY: clean
	rm bin/Chameneos*
	rm *.class   