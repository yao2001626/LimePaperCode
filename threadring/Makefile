#Makefile for threadring example
#author: Shucai yao
#time: 2020.08.24

.SUFFIXES: .hs
    
GHC     = ghc 
FLAGS   = -threaded -O -rtsopts --make
IDIR    = src
ODIR    = bin
MODULES = $(patsubst $(IDIR)/%.hs, $(ODIR)/%, $(wildcard $(IDIR)/*.hs))

all: bin/threadring_go bin/threadring_haskell bin/threadring_pthread bin/threadring_pthread_mon bin/threadring_rust bin/threadring.beam bin/%.class bin/threadring_lime

bin/threadring_haskell: src/threadring.hs
	$(GHC) $(FLAGS)  -o $@ $<

#bin/threadring_lime: src/threadring.lime
#	limec -o $@ $<

bin/threadring_go: src/threadring.go
	go build -o $@ $<

bin/threadring_pthread: src/threadring.c
	gcc -pthread -o $@ $<

bin/threadring_pthread_mon: src/threadring.mon.c
	gcc -pthread -o $@ $<

bin/threadring_rust: src/threadring.rs
	rustc -o $@ $<
bin/threadring.beam: src/threadring.erl
	erlc -W -o bin $<
bin/%.class: src/threadring.java
	javac -d bin $<   
bin/threadring_lime: src/threadring.lime
	cd src && limec threadring.lime -o ../bin/threadring_lime

.PHONY: clean
	rm threadring* 
	rm *.class  