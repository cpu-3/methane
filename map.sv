`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/15 12:58:26
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
module map(
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
    
    reg [31:0] din_reg;
    reg [31:0] addr_reg;
    reg [3:0] write_enable_reg;
    reg [31:0] c_dout_reg;
    reg [7:0] led_reg;
    
    parameter led_addr = 32'h10008;
    
    assign led = c_write_enable && (c_addr == led_addr) ? c_din[31:24] : led_reg;
    assign addr = c_addr == led_addr ? addr_reg : c_addr;
    assign write_enable = c_addr == led_addr ? write_enable_reg : c_write_enable;
    assign din = c_addr == led_addr ? din_reg : c_din;
    assign c_dout = c_addr == led_addr ? c_dout_reg : dout;

    always @(posedge clk) begin
        if (~rstn) begin
            led_reg <= 8'd0;
            addr_reg <= 32'd0;
            write_enable_reg <= 4'd0;
            c_dout_reg <= 32'd0;
            din_reg <= 32'd0;
        end else begin
            led_reg <= led;
            addr_reg <= addr;
            write_enable_reg <= write_enable;
            din_reg <= din;
            c_dout_reg <= c_dout;
        end 
    end
    
endmodule
