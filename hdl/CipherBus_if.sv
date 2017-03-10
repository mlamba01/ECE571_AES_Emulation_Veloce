// Module: CipherBus_if.sv
// Author: Rehan Iqbal
// Date: March 8, 2017
// Company: Portland State University
//
// Description:
// ------------
//
// clk - global clock signal
// reset - active high global async reset
// 
// i_data[128] - plain or cipher text data input to the core. 
// Bus holds the value of data for the encryption/decryption operation. 
// This bus is sampled when a new operation is started and may be changed 
// after the operation started.
//
// i_data_valid - data input valid pulse indiciates that the data input bus is valid 
// and start encryption/decryption if the core is read for new data. 
// Signal should be asserted if o_read signal was not asserted at the previous clock cycle
//
// i_ende - mode of operation selection ccontrol. 
// Low: core will encrypt the input data. 
// High: core will decrypt the input data.
//
// i_enable - clock enable control
//
// o_data[128] - plain or cipher text data output from the core. This bus presents 
// the value of the data output from the encryption/decryption operation.
//
// o_data_valid - output data bus valid pulse indicating that the value on the 
// o_data bus has changed and holds the result of the corresponding operation.
//
// o_ready - input ready for new data output. This signal indicates that the 
// core is ready for a new input data on the next clock cycle. This signal is 
// generated from internal state of core and only valid for the next clock cycle 
// since the new data is push inthe processing pipeline off the algorithm.
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

interface CipherBus_if (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

	input	ulogic1		clk,
	input	ulogic1		resetH

	);

	/************************************************************************/
	/* Bus signals															*/
	/************************************************************************/
	
	ulogic1		i_enable;
	ulogic1		i_ende;
	ulogic1		i_data_valid;
	ulogic128	i_data;

	ulogic1		o_ready;
	ulogic1		o_data_valid;
	ulogic128	o_data;

	/************************************************************************/
	/* Modport : master														*/
	/************************************************************************/

	modport master (

		input	clk,
		input	resetH,

		output	i_enable,
		output	i_ende,
		output	i_data,
		output	i_data_valid,

		input	o_ready,
		input	o_data_valid,
		input	o_data

		);

	/************************************************************************/
	/* Modport : slave														*/
	/************************************************************************/

	modport slave (

		input	clk,
		input	resetH,

		input	i_enable,
		input	i_ende,
		input	i_data,
		input	i_data_valid,

		output	o_ready,
		output	o_data_valid,
		output	o_data

		);

endinterface : CipherBus_if