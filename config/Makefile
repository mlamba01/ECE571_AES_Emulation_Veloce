## File: Makefile
## Author: Rehan Iqbal
## Date: March 18, 2017
## Company: Portland State University
##
## Description:
##
## Use this to compile & run the HDL & HVL on Veloce / Co-Model Server.
## Once design is working, can simply use 'make all' command.
##
################################################################################

# Specify the mode - could be either Puresim or Veloce (default)
# Make sure design works in Puresim before changing to Veloce!

# e.g.	make work MODE="puresim"
#		make build MODE="puresim"

MODE ?= veloce

# "make all" command does everything
# create the libraries, build/compile, then run

all: work build run

# Create respective work libs and map them

work:
	vlib work.$(MODE)
	vmap work work.$(MODE)
	
# Compile modules & synthesize the environment

build:
	vlog definitions.sv			# Compile the package
	vlog top_hvl.sv				# Compile the testbench 

ifeq ($(MODE),puresim)			# Puresim-mode: compile everything else

	vlog KeyBus_if.sv			# Compile the KeyBus interface
	vlog CipherBus_if.sv		# Compile the CipherBus interface
	vlog Testbench_if.sv		# Compile the Testbench interface

	vlog inv_shift_rows.sv		# Compile the inv_shift_rows module
	vlog key_exp.sv				# Compile the key_exp module
	vlog mix_columns.sv			# Compile the mix_columns module
	vlog ram_16x64.sv			# Compile the ram_16x64 module
	vlog sbox.sv				# Compile the sbox module
	vlog shift_rows.sv			# Compile the shift_rows module
	vlog xram_16x64.sv			# Compile the xram_16x64 module
	vlog aes.sv					# Compile the aes module

	vlog top_hdl.sv				# Compile the top-level HDL

	# specify the sim mode for velhvl. Default is 'veloce'
	# use 'puresim' to execute simulation of user's files

	velhvl -sim $(MODE)

else									# Otherwise, synthesize for Veloce-mode
	
	velanalyze definitions.sv								# Analyze the package for synthesis
	velanalyze -extract_hvl_info +define+QUESTA top_hvl.sv	# Analyze the top-HVL for external task calls in BFM 

	velanalyze KeyBus_if.sv				# Analyze the KeyBus interface for synthesis
	velanalyze CipherBus_if.sv			# Analyze the CipherBus interface for synthesis
	velanalyze Testbench_if.sv			# Analyze the Testbench interface for synthesis

	velanalyze inv_shift_rows.sv		# Analyze the inv_shift_rows module for synthesis
	velanalyze key_exp.sv				# Analyze the key_exp module for synthesis
	velanalyze mix_columns.sv			# Analyze the mix_columns module for synthesis
	velanalyze ram_16x64.sv				# Analyze the ram_16x64 module for synthesis
	velanalyze sbox.sv					# Analyze the sbox module for synthesis
	velanalyze shift_rows.sv			# Analyze the shift_rows module for synthesis
	velanalyze xram_16x64.sv			# Analyze the xram_16x64 module for synthesis
	velanalyze aes.sv					# Analyze the aes module for synthesis
	
	velanalyze top_hdl.sv				# Analyze the HDL top for synthesis 

	# run the velcomp command
	# this actually runs a number of steps, influenced by veloce.config file

	# - analyzes RTL *
	# - compiles RTL (rtlc)
	# - synthesizes (velsyn)
	# - compiles HVL (hvl) **
	# - place and route Veloce Crystal Chips (velcc)
	# - set up timing database (velgs)
	# - setup up replay system (ssrcc)

	# *  = only if single-step analysis enabled in veloce.config
	# ** = only if 'hvl' option enabled in veloce.config

	velcomp -top top_hdl

	# specify the sim mode for velhvl. Default is 'veloce'
	# use 'puresim' to execute simulation of user's files

	velhvl -sim $(MODE)

endif

run:

	# vsim command runs emulation for SystemVerilog testbenches from Questa
	# (velrun works for C, C++, SystemC testbenches)

	# -c flag sets command-line mode
	# -do flag executes the command "run -all" on startup (could also specify file)

	vsim -c -do vsim.do top_hvl top_hdl			# Run for the entire simulation 
	cp transcript transcript.$(MODE)			# Record transcript

norun:	# No run lets you control stepping etc. 
	vsim -c +tbxrun+norun top_hvl top_hdl -cpppath $(CPP_PATH)
	cp transcript transcript.$(MODE)

# remove results of the last simulation from folder
# including compilation files, logs, etc.

clean:
	rm -rf tbxbindings.h modelsim.ini transcript.veloce transcript.puresim work work.puresim work.veloce transcript *~ vsim.wlf *.log dgs.dbg dmslogdir veloce.med veloce.wave veloce.map velrunopts.ini edsenv top_hvl_results.txt vish_stacktrace.vstf