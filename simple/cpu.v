`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:28 06/13/2017 
// Design Name: 
// Module Name:    cpu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cpu(mem_addr, mem_we_d, mem_we_v, gpo, b, clock, reset, gpi, gpi_we, douta_mem_d);
	input			    clock;
	input			    reset;
	input	[7:0]	    gpi;
	input			    gpi_we;
	input	[7:0]		douta_mem_d;
	output	[15:0]		mem_addr;
	output				mem_we_d;
	output				mem_we_v;
	output 	[7:0]	    gpo;
   	output 	[7:0]		b; 

	wire 	[7:0]	    alu_out;
	wire 		    	E_out;
   	wire  	[7:0]		a;
   	wire  				E;
	wire 	[7:0]	    pc;
	wire 	[3:0]		opcode;
	wire	[3:0]	    raddr1;
	wire	[3:0]	    raddr2;
	wire	[3:0]	    waddr;

alu alu(
				.alu_out(alu_out), 
				.E_out(E_out),
				.a(a),
				.b(b),
				.E(E),
				.opcode(opcode)
			);
register_file register_file(
				.a(a),
				.b(b),
				.E(E),
				.pc(pc),
				.mem_addr(mem_addr),
				.mem_we_d(mem_we_d),
				.mem_we_v(mem_we_v),
				.gpo(gpo),
				.clock(clock),
				.reset(reset),
				.alu_out(alu_out),
				.E_out(E_out),
				.opcode(opcode),
				.raddr1(raddr1),
				.raddr2(raddr2),
				.waddr(waddr),
				.gpi(gpi),
				.gpi_we(gpi_we),
				.douta_mem_d(douta_mem_d)
			);
myrom myrom(
				.clka(clock),
				.addra(pc),
				.douta({opcode, raddr1, raddr2, waddr})
			);
endmodule
//single-port ram i/o pins: clka, wea, addra, dina, douta
