`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/21 13:34:58
// Design Name: 
// Module Name: uart.v
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


module uart_wrapper(
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
    uart(.rx_ready(rx_ready),
         .tx_ready(tx_ready),
         .r_data(r_data),
         .t_data(t_data),
         .t_valid(t_valid),
         .axi_awvalid(axi_awvalid),
         .axi_awready(axi_awready),
         .axi_awaddr(axi_awaddr),
         .axi_awprot(axi_awprot),
         .axi_wvalid(axi_wvalid),
         .axi_wready(axi_wready),
         .axi_wdata(axi_wdata),
         .axi_wstrb(axi_wstrb),
         .axi_bvalid(axi_bvalid),
         .axi_bready(axi_bready),
         .axi_bresp(axi_bresp),
         .axi_arvalid(axi_arvalid),
         .axi_arready(axi_arready),
         .axi_araddr(axi_araddr),
         .axi_arprot(axi_arprot),
         .axi_rvalid(axi_rvalid),
         .axi_rready(axi_rready),
         .axi_rdata(axi_rdata),
         .axi_rresp(axi_rresp),
         .clk(clk),
         .rstn(rstn)
     );
endmodule
