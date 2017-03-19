// Module: KeyBus_if.sv
// Author: Rehan Iqbal
// Date: March 18, 2017
// Company: Portland State University
//
// Description:
//
// This modules represents the bus containing signals for creating keys,
// going into & out of the AES core. Used to simplify connections in "top_hdl.sv"
// module. It contains two ports - master (top_hdl) & slave (AES).
//
// The signals are defined as:
// 
// i_start - key expansion start pulse signal
// i_key_mode [2] - 2'b00 = 128 bit, 2'b01 = 192 bit, 2'b10 = 256 bit
// i_key [256] - key value input bus
// 
// o_key_ready - key expansion is done and expanded key is ready for use. 
// Level signal that will only clear after reset and during expansion 
// of a new key triggered using i_start input
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

interface KeyBus_if (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

	input	ulogic1		clk,
	input	ulogic1		resetH

	);

	/************************************************************************/
	/* Bus signals															*/
	/************************************************************************/

	ulogic1			i_start			= 1'b0;
	ulogic2			i_key_mode		= 2'd0;
	ulogic256		i_key			= 256'd0;

	ulogic1			o_key_ready;

	/************************************************************************/
	/* Modport : master														*/
	/************************************************************************/

	modport master (

		input	clk,
		input	resetH,

		output	i_key,
		output	i_key_mode,
		output	i_start,

		input	o_key_ready

		);

	/************************************************************************/
	/* Modport : slave														*/
	/************************************************************************/

	modport slave (

		input	clk,
		input	resetH,

		input	i_key,
		input	i_key_mode,
		input	i_start,

		output	o_key_ready

		);

endinterface : KeyBus_if