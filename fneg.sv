`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/06 15:24:52
// Design Name: 
// Module Name: fneg
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


module fsgnj(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output wire [31:0] y
    );
    assign y = {x2[31], x1[30:0]};
endmodule

module fsgnjn(
    input wire [31:0] x1,
    input wire [31:0] x2,
    output wire [31:0] y
    );
    assign y = {~x2[31], x1[30:0]};
endmodule
