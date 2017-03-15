## File: Makefile
## Author: Rehan Iqbal
## Date: March 13, 2017
## Company: Portland State University
##
## Description:
## ------------
##
################################################################################

all: clean compile run

clean:
	rm -rf demo

compile: 
	gcc -Wall demo.c aes256.c -o demo

run: 
	./demo