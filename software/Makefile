## File: Makefile
## Author: Rehan Iqbal
## Date: March 13, 2017
## Company: Portland State University
##
## Description:
## ------------
##
################################################################################

all: clean build run

clean:
	rm -rf demo output.txt

build: 
	gcc -Wall -std=c99 demo.c aes256.c -o demo

run: 
	./demo "trace.txt"