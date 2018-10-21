`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/21 14:01:58
// Design Name: 
// Module Name: loopback
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


module loopback_core(
    input  wire clk,
    input  wire  rstn,
    input  wire rx_ready,
    input  wire tx_ready,
    input  wire [7:0]r_data,
    output reg [7:0]t_data,
    output reg t_valid
    );
    reg [7:0] data;
    reg [1:0] state;
    
    always @(posedge clk) begin
        if (~rstn) begin
            data <= 8'b0;
            state <= 2'b0;
        end else begin
            if (state == 2'b0) begin
                t_valid <= 1'b0;
                if (rx_ready) begin
                    data <= r_data;
                    state <= 2'b1;
                end
            end else if (state == 2'b1) begin
                if (tx_ready) begin
                    t_data <= data;
                    t_valid <= 1'b1;
                    state <= 2'b0;
                end
            end
        end
    end    
endmodule
