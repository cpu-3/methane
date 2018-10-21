`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/21 13:25:01
// Design Name: 
// Module Name: uart
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


module uart (
    // interface
    output reg rx_ready,
    output reg tx_ready,
    output reg [7:0]r_data,
    input  wire [7:0]t_data,
    input  wire t_valid,

    // for uartlite
    output wire                      axi_awvalid,
    input wire                       axi_awready,
    output wire [31:0]               axi_awaddr,
    output reg [2:0]                 axi_awprot,
    // data write channel
    output wire                      axi_wvalid,
    input wire                       axi_wready,
    output reg [31:0]                axi_wdata,
    output reg [3:0]                 axi_wstrb,
    // response channel
    input wire                       axi_bvalid,
    output wire                      axi_bready,
    input wire [1:0]                 axi_bresp,
    // address read channel
    output wire                      axi_arvalid,
    input wire                       axi_arready,
    output reg [3:0]                axi_araddr,
    output reg [2:0]                 axi_arprot,
    // read data channel
    input wire                       axi_rvalid,
    output reg                       axi_rready,
    input wire [3:0]                axi_rdata,
    input wire [1:0]                 axi_rresp,

    input wire                       clk,
    input wire                       rstn);
    
endmodule
