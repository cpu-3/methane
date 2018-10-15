`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/15 12:58:43
// Design Name: 
// Module Name: map
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


// memory proxy. maps connections by receiveved addr.
module map_wrapper(
    // to ports 
    input wire clk, 
    input wire rstn,
    output wire [7:0] led,
    
    output wire [31:0] din,
    output wire [31:0] addr,
    output wire [3:0] write_enable,
    input  wire [31:0] dout,
    
    // from/to core
    input wire [31:0] c_din,
    input wire [31:0] c_addr,
    input wire [3:0] c_write_enable,
    output wire [31:0] c_dout

    );
    map map(
        .clk(clk),
        .rstn(rstn),
        .led(led), 
        .din(din), 
        .addr(addr), 
        .write_enable(write_enable),
        .dout(dout),
        .c_din(c_din),
        .c_write_enable(c_write_enable),
        .c_dout(c_dout),
        .c_addr(c_addr)
    );
endmodule
