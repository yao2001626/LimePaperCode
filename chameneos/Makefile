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

bin/Chameneos_haskell: src/Chameneos.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/Chameneos_lime: src/Chameneos.lime
#	limec -o $@ $<

bin/Chameneos_go: src/Chameneos.go
	go build -o $@ $<

bin/Chameneos_pthread: src/Chameneos.c
	gcc -pthread -o $@ $<

#bin/Chameneos_rust: src/Chameneos.rs
#	rustc -o $@ $<

bin/Chameneos.beam: src/Chameneos.erl
	erlc -W -o bin $<
bin/%.class: src/Chameneos.java
	javac -d bin $<   
#bin/Chameneos_lime: src/Chameneos.lime
#	cd src && limec Chameneos.lime -o ../bin/Chameneos_lime
.PHONY: clean
	rm bin/Chameneos*   