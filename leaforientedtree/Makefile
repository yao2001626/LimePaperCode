#Makefile for Leaf Oriented Tree example
#Author: Shucai Yao
#Time: 2020.10.28

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/LOT_go bin/LOT_haskell bin/LOT_pthread bin/lot.beam bin/%.class 

bin/LOT_haskell: src/LOT.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/LOT_lime: src/LOT.lime
#	limec -o $@ $<

bin/LOT_go: src/LOT.go
	go build -o $@ $<

bin/LOT_pthread: src/LOT.c
	gcc -pthread -o $@ $<

#bin/LOT_rust: src/LOT.rs
#	rustc -o $@ $<
bin/lot.beam: src/lot.erl
	erlc -W -o bin $<
bin/%.class: src/LOT.java
	javac -d bin $<   
#bin/LOT_lime: src/LOT.lime
#	cd src && limec LOT.lime -o ../bin/LOT_lime
.PHONY: clean
	rm bin/LOT*   
