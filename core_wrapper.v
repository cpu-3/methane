`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/09/28 17:28:58
// Design Name: 
// Module Name: core_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module core_wrapper(
    input wire clk,
    input wire rstn,

    input wire [31:0] instr,
    output wire [31:0] pc,
    output wire [3:0] instr_we,
    output wire [31:0] instr_in,

    output wire [31:0] din,
    output wire [31:0] addr,
    input wire [31:0] dout,
    output wire [3:0]data_we,

    input wire memory_done,
    output wire load
    );
    core c(clk, rstn, instr, pc, instr_we, instr_in, din, addr, dout, data_we, memory_done, load);

endmodule

