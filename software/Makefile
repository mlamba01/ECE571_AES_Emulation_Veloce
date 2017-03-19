## File: Makefile
## Author: Rehan Iqbal
## Date: March 13, 2017
## Company: Portland State University
##
## Description:
##
## Use this to compile & run 'demo.c' software. This program provides a SW
## version of AES encryption/decryption which can be compared against the HW
## results running on QuestaSim & Veloce.
##
################################################################################

# 'make all' command does everything
# clean the directory, build/compile, then run

all: clean build run

# clean results of last compilation & run out of folder
clean:
	rm -rf demo output.txt

# compile using C99 compiler
build: 
	gcc -Wall -std=c99 demo.c aes256.c -o demo

# run demo, looking for "trace.txt" as input argument
run: 
	./demo "trace.txt"