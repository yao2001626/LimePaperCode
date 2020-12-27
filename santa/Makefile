#Makefile for santa example
#author: Shucai yao
#time: 2020.08.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/santa_go bin/santa_haskell bin/santa_pthread  bin/santa.beam bin/%.class #bin/santa_lime

bin/santa_haskell: src/santa.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/santa_lime: src/santa.lime
#	limec -o $@ $<

bin/santa_go: src/santa.go
	go build -o $@ $<

bin/santa_pthread: src/santa.c
	gcc -pthread -o $@ $<

#bin/santa_rust: src/santa.rs
#	rustc -o $@ $<
bin/santa.beam: src/santa.erl
	erlc -W -o bin $<
bin/%.class: src/santa.java
	javac -d bin $<   
#bin/santa_lime: src/santa.lime
#	cd src && limec santa.lime -o ../bin/santa_lime
.PHONY: clean
	rm santa*   