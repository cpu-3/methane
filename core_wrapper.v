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
    output wire led0,
    output wire led1
    );
    core(clk, rstn, led0, led1);

endmodule
