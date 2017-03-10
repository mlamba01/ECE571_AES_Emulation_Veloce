// Module: definitions.pkg
// Author: Rehan Iqbal
// Date: March 9th, 2017
// Company: Portland State University
//
// Description:
// ------------
// Package definitions file for the memController module & testbench. Contains
// type definitions for unsigned vars and parameters for FSM states.
//
// Include in target modules through syntax: `include "definitions.pkg"
// Make sure library paths include this file!
// 
//////////////////////////////////////////////////////////////////////////////
	
// check if file has been imported already
`ifndef IMPORT_DEFS

	// make sure other modules dont' re-import
	`define IMPORT_DEFS

	package definitions;

		// type definitions for unsigned 4-state variables
		typedef	logic		unsigned			ulogic1;
		typedef	logic		unsigned	[1:0]	ulogic2;
		typedef	logic		unsigned	[3:0]	ulogic4;
		typedef	logic		unsigned	[7:0]	ulogic8;
		typedef logic		unsigned	[11:0]	ulogic12;
		typedef	logic		unsigned	[15:0]	ulogic16;
		typedef	logic		unsigned	[31:0]	ulogic32;
		typedef	logic		unsigned	[63:0]	ulogic64;
		typedef	logic		unsigned	[63:0]	ulogic128;
		typedef	logic		unsigned	[63:0]	ulogic256;

		// type definitions for unsigned 2-state variables
		typedef bit			unsigned			uint1;
		typedef	bit			unsigned	[1:0]	uint2;
		typedef	bit			unsigned	[3:0]	uint4;
		typedef	byte		unsigned			uint8;
		typedef	shortint	unsigned			uint16;
		typedef	int			unsigned			uint32;
		typedef	longint		unsigned			uint64;

	endpackage

	// include the above definitions in the modules
	import definitions::*;

`endif