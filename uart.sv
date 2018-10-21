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
    output reg rx_done,
    output reg tx_done,
    input  wire t_valid,

    // for uartlite
    output reg                       axi_awvalid,
    input wire                       axi_awready,
    output reg  [3:0]                axi_awaddr,
    output reg [2:0]                 axi_awprot,
    // data write channel
    output reg                       axi_wvalid,
    input wire                       axi_wready,
    output wire [31:0]               axi_wdata,
    output reg [3:0]                 axi_wstrb,
    // response channel
    input wire                       axi_bvalid,
    output wire                      axi_bready,
    input wire [1:0]                 axi_bresp,
    // address read channel
    output reg                       axi_arvalid,
    input wire                       axi_arready,
    output reg [3:0]                 axi_araddr,
    output reg [2:0]                 axi_arprot,
    // read data channel
    input wire                       axi_rvalid,
    output reg                       axi_rready,
    input wire [31:0]                axi_rdata,
    input wire [1:0]                 axi_rresp,

    input wire                       clk,
    input wire                       rstn);
        
    localparam s_wait = 3'b000;
    localparam s_read_status = 3'b001;
    localparam s_write_data  = 3'b010;
    
    localparam rx_fifo  = 4'h0;
    localparam tx_fifo  = 4'h4;
    localparam stat_reg = 4'h8;
    localparam ctrl_reg = 4'hc;
    reg [2:0] transmit_status;
    
    wire [7:0]rx_data;
    assign rx_data = axi_rdata[7:0];
    reg  [7:0]tx_data;
    assign axi_wdata = {24'd0, tx_data};
    
    // tx
    always @(posedge clk) begin
        if (~rstn) begin
            // always 0 (perhaps..)
            axi_arprot <= 3'b0;
            rx_done <= 1'b0;
            tx_done <= 1'b0;
        end else if(s_wait == transmit_status) begin
            tx_done <= 1'b0;
            if (t_valid) begin
                transmit_status <= s_read_status;
                // first read status
                axi_arvalid <= 1'b1;
                axi_araddr <= stat_reg;            
                axi_rready <= 1'b1;
            end
        end else if (transmit_status == s_read_status) begin
            if (axi_rvalid) begin
                 // if tx fifo is full then wait for a space
                 if(rx_data[3]) begin
                     axi_arvalid <= 1'b1;
                     axi_araddr <= stat_reg;
                     
                     axi_rready <= 1'b1;
                 end else begin
                    // there exists a space for transmission 
                    axi_arvalid <= 1'b0;
                    axi_rready <= 1'b0;
                    
                    // write tran_addr reg
                    // and simultaneously write data
                    axi_awvalid <= 1'b1;
                    axi_awaddr <= tx_fifo;
                    axi_wvalid <= 1'b1;
                    tx_data <= t_data;
                    
                    transmit_status <= s_write_data;
                 end
            end else if (axi_arvalid) begin
                 axi_arvalid <= 1'b0;
            end 
        end else if (transmit_status == s_write_data) begin
            // after trasmission finishes, 
            // notifies tx_done to the sender  and wait for the next. 
            if (axi_awready && axi_wready) begin
                axi_awvalid <= 1'b0;
                axi_wvalid <= 1'b0;
                transmit_status <= s_wait;
                tx_done <= 1'b1;
            end else if (axi_awready) begin
                axi_awvalid <= 1'b0;
                if (axi_wvalid == 1'b0) begin
                    transmit_status <= s_wait;
                    tx_done <= 1'b1;
                end
            end else if (axi_wready) begin
                axi_wvalid <= 1'b0;
                if (axi_awvalid == 1'b0) begin
                    transmit_status <= s_wait;
                    tx_done <= 1'b1;
                end
            end
        end
    end
    
    // rx
    always @(posedge clk) begin
    end

endmodule
