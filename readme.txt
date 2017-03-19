This directory contains all materials for the AES core project.

\hdl - contains all the SystemVerilog (.sv) files used to create the device-under-test (DUT).
\hvl - contains all the SystemVerilog (.sv) files used to create the testebench.
\software - contains all the files needed to compile & run the C program.
\config - contains the Makefile for compiling HVL & HDL, along with some .do files for running simulation. Also contains veloce.config, which is needed for emulation.

To run the project on Veloce:

1) copy all files in \hdl, \hvl, and \config to a directory on velocesolo.ece.pdx.edu
2) open bash shell and run make all - this will compile & build code, then synthesize run on the emulator
3) check the results in "top_hvl_results.txt". Can also check veloce.transcript for some statistics about the run.
4) copy the "trace.txt" file to the \software directory
5) open bash shell and run 'make all' within \software - this will compile & build C program, then run using "trace.txt" as input
6) check results in 'output.txt' against 'top_hvl_results.txt'

To run the project on PureSim (no emulator - all server):

1) copy all files in \hdl, \hvl, and \config to a directory on velocesolo.ece.pdx.edu
2) open bash shell and run make all mode="puresim" - this will compile & build code, then synthesize run on the emulator
3) check the results in "top_hvl_results.txt".
4) copy the "trace.txt" file to the \software directory
5) open bash shell and run 'make all' within \software - this will compile & build C program, then run using "trace.txt" as input
6) check results in 'output.txt' against 'top_hvl_results.txt'

To run the project in QuestaSim with GUI (waveform of signals):

1) copy all files in \hdl, \hvl, and \config to a directory on velocesolo.ece.pdx.edu
2) open bash shell and run make clean, make work mode="puresim", and then make build mode="puresim"
3) run QuestaSim in GUI mode using vsim -gui
4) select 'top_hvl.sv' and 'top_hdl.sv', right-mouse click and 'simulate'
5) bring up Wave window and File > Load the config\wave.do file
6) run simulation until finish and check waveform