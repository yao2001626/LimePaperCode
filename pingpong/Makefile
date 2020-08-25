#Makefile for PingPong example
#author: Shucai yao
#time: 2020.08.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/pingpong_go bin/pingpong_haskell bin/pingpong_pthread bin/pingpong_rust bin/pingpong.beam bin/%.class bin/pingpong_lime

bin/pingpong_haskell: src/pingpong.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/pingpong_lime: src/pingpong.lime
#	limec -o $@ $<

bin/pingpong_go: src/pingpong.go
	go build -o $@ $<

bin/pingpong_pthread: src/pingpong.c
	gcc -pthread -o $@ $<

bin/pingpong_rust: src/pingpong.rs
	rustc -o $@ $<
bin/pingpong.beam: src/pingpong.erl
	erlc -W -o bin $<
bin/%.class: src/pingpong.java
	javac -d bin $<   
bin/pingpong_lime: src/pingpong.lime
	cd src && limec pingpong.lime -o ../bin/pingpong_lime
.PHONY: clean
	rm pingpong*   