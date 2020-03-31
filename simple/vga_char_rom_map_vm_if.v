`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:40:27 06/13/2017 
// Design Name: 
// Module Name:    vga_char_rom_map_vm_if 
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
`timescale 1ns / 1ps

module vga(CLK_50M, VGA_R, VGA_G, VGA_B, VGA_HSYNC, VGA_VSYNC, mem_addr, mem_we_v, b);//

	input CLK_50M;	
	output [3:0] VGA_R;
	output [3:0] VGA_G;
	output [3:0] VGA_B;
	output VGA_HSYNC;
	output VGA_VSYNC;
	input 	[12:0]	mem_addr;//
	input 			mem_we_v;//
	input 	[7:0]	b;//

	reg clk_25m;
	wire clk;
	assign clk = clk_25m;

	reg [9:0] hcount;
	reg [9:0] vcount;

	reg [9:0] hcount_delayed;
	reg [9:0] hcount_delayed2;//
	reg [9:0] vcount_delayed;
	reg [9:0] vcount_delayed2;//
	
	reg [3:0] vga_r_out;
	reg [3:0] vga_g_out;
	reg [3:0] vga_b_out;
	reg vga_hsync_out;
	reg vga_vsync_out;

	assign VGA_R = vga_r_out;
	assign VGA_G = vga_g_out;
	assign VGA_B = vga_b_out;
	assign VGA_HSYNC = vga_hsync_out;
	assign VGA_VSYNC = vga_vsync_out;

	parameter H_ACTIVE_PIXEL_LIMIT = 639;
	parameter H_FPORCH_PIXEL_LIMIT = 656; // 640+16
	parameter H_SYNC_PIXEL_LIMIT   = 752; // 640+16+96
	parameter H_BPORCH_PIXEL_LIMIT = 799; // 640+16+96+48

	parameter V_ACTIVE_LINE_LIMIT = 479;
	parameter V_FPORCH_LINE_LIMIT = 490; // 480+10
	parameter V_SYNC_LINE_LIMIT   = 492; // 480+10+2
	parameter V_BPORCH_LINE_LIMIT = 520; // 480+10+2+29

wire [7:0] mapout;//
wire [7:0] dout;
wire pixel;
assign pixel = dout[7-hcount_delayed2[2:0]];//

//80x60x8bit map_rom (address 13 bits, data 1 byte)
//map_rom map_rom(.clka(clk), .addra({vcount[8:3],hcount[9:3]}),.douta(mapout));
map_ram map_ram(.clka(CLK_50M), .addra(mem_addr), .dina(b), .wea(mem_we_v), .clkb(clk), .addrb({vcount[8:3],hcount[9:3]}),.doutb(mapout)); //<- dual-port ram

//256x8x8bit character_rom (address 11 bits, data 1 byte)
char_rom char_rom(.clka(clk), .addra({mapout,vcount_delayed[2:0]}), .douta(dout));

always @(posedge CLK_50M)
begin
	clk_25m <= clk_25m + 1;
end

always @(posedge clk)
begin
	if (hcount < H_BPORCH_PIXEL_LIMIT)
		hcount <= hcount + 1;
	else
		begin
			hcount <= 0;
			if (vcount < V_BPORCH_LINE_LIMIT)
			   	vcount <= vcount + 1;
			else 
				vcount <= 0;
		end
end

always @(posedge clk)
begin
	if (hcount_delayed2 <= H_ACTIVE_PIXEL_LIMIT &&
		vcount_delayed2 <= V_ACTIVE_LINE_LIMIT) // active video region
		begin
			vga_r_out <= {pixel,pixel,pixel,pixel};
			vga_g_out <= {pixel,pixel,pixel,pixel};
			vga_b_out <= {pixel,pixel,pixel,pixel};
		end
	else
	case (hcount_delayed2)
		H_ACTIVE_PIXEL_LIMIT+1: // front porch
			begin
				vga_r_out <= 4'd0;
				vga_g_out <= 4'd0;
				vga_b_out <= 4'd0;
			end
		H_FPORCH_PIXEL_LIMIT: // sync pulse
				vga_hsync_out <= 1'b0;
		H_SYNC_PIXEL_LIMIT: // back porch
				vga_hsync_out <= 1'b1;
	endcase

	case (vcount_delayed2)
		V_FPORCH_LINE_LIMIT: // sync pulse
			vga_vsync_out <= 1'b0;
		V_SYNC_LINE_LIMIT: // back porch
			vga_vsync_out <= 1'b1;
	endcase
end

always @(posedge clk)
begin	
			hcount_delayed <= hcount;
			hcount_delayed2 <= hcount_delayed;//
			vcount_delayed <= vcount;
			vcount_delayed2 <= vcount_delayed;//
end

endmodule

