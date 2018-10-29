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

typedef enum reg [2:0] {
    u_wait, u_read_status_transmit, u_transmit_data, u_read_status_receive, u_receive_data
} s_uart;

module uart (
    // interface
    output reg u_ready,
    output reg [7:0]r_data,
    input  wire [7:0]t_data,
    output reg rx_done,
    output reg tx_done,
    input  wire t_valid,
    input  wire r_valid,

    // for uartlite
    output reg                       axi_awvalid,
    input wire                       axi_awready,
    output reg  [3:0]                axi_awaddr,
    // data write channel
    output reg                       axi_wvalid,
    input wire                       axi_wready,
    output wire [31:0]               axi_wdata,
    output reg [3:0]                 axi_wstrb,
    // response channel
    input wire                       axi_bvalid,
    output reg                       axi_bready,
    input wire [1:0]                 axi_bresp,
    // address read channel
    output reg                       axi_arvalid,
    input wire                       axi_arready,
    output reg [3:0]                 axi_araddr,
    // read data channel
    input wire                       axi_rvalid,
    output reg                       axi_rready,
    input wire [31:0]                axi_rdata,
    input wire [1:0]                 axi_rresp,
    
    input wire                       clk,
    input wire                       rstn);
            
    localparam rx_fifo  = 4'h0;
    localparam tx_fifo  = 4'h4;
    localparam stat_reg = 4'h8;
    localparam ctrl_reg = 4'hc;
    s_uart status;
    
    wire [7:0]rx_data;
    assign rx_data = axi_rdata[7:0];
    reg  [7:0]tx_data;
    assign axi_wdata = {24'd0, tx_data};
    
    reg [7:0] led_r;
    //assign led = led_r;
    
    // tx
    always @(posedge clk) begin
        if(axi_bvalid) begin 
            axi_bready <= 1'b1;
        end else begin
            axi_bready <= 1'b0;
        end
    
        if (~rstn) begin
            // always 0 (perhaps..)
            tx_done <= 1'b0;
            rx_done <= 1'b0;
            axi_arvalid <= 1'b0;
            axi_araddr <= stat_reg;
            axi_rready <= 1'b0;
            axi_wstrb <= 4'b0001;
            axi_wvalid <= 1'b0;
            axi_awaddr <= 4'b0;
            axi_awvalid <= 1'b0;
            
            u_ready <= 1'b0;
            status <= u_wait;
            tx_data <= 8'b0;
            r_data <= 8'b0;
            led_r <= 8'b0;
        end else if(u_wait == status) begin
            tx_done <= 1'b0;
            rx_done <= 1'b0;
            if (t_valid) begin
                status <= u_read_status_transmit;
                // first read status
                axi_arvalid <= 1'b1;
                axi_araddr <= stat_reg;            
                axi_rready <= 1'b1;
                u_ready <= 1'b0;
            end else if(r_valid) begin
                status <= u_read_status_receive;
                axi_arvalid <= 1'b1;
                axi_araddr <= stat_reg;            
                axi_rready <= 1'b1;
                u_ready <= 1'b0;
            end else begin
                u_ready <= 1'b1;
            end
        end else if (status == u_read_status_transmit) begin
            led_r <= rx_data;

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
                    
                    status <= u_transmit_data;
                 end
            end else if (axi_arready) begin
                 axi_arvalid <= 1'b0;
            end 
        end else if (status == u_read_status_receive) begin
            led_r <= rx_data;

            if (axi_rvalid) begin
                 // check if there is a data delivered.
                 if (~rx_data[0]) begin // 1 is valid, 0 is empty (hoge)
                     axi_arvalid <= 1'b1;
                     axi_araddr <= stat_reg;
                     
                     axi_rready <= 1'b1;
                 end else begin
                 // there exists a data 
                    axi_arvalid <= 1'b1;
                    axi_rready <= 1'b1;
                    axi_araddr <= rx_fifo;                        
                    status <= u_receive_data;
                 end
            end else if (axi_arready) begin
                axi_arvalid <= 1'b0;
            end 
        end else if (status == u_transmit_data) begin
            // after trasmission finishes, 
            // notifies tx_done to the sender  and wait for the next. 
            if (axi_awready && axi_wready) begin
                axi_awvalid <= 1'b0;
                axi_wvalid <= 1'b0;
                status <= u_wait;
                tx_done <= 1'b1;
                u_ready <= 1'b1;
            end else if (axi_awready) begin
                axi_awvalid <= 1'b0;
                if (axi_wvalid == 1'b0) begin
                    status <= u_wait;
                    tx_done <= 1'b1;
                    u_ready <= 1'b1;
                end
            end else if (axi_wready) begin
                axi_wvalid <= 1'b0;
                if (axi_awvalid == 1'b0) begin
                    status <= u_wait;
                    tx_done <= 1'b1;
                    u_ready <= 1'b1;
                end
            end
        end else if (status == u_receive_data) begin
            if (axi_arready) begin
                 axi_arvalid <= 1'b0;
            end
            if (axi_rvalid) begin
                axi_rready <= 1'b0;
                
                rx_done <= 1'b1;
                r_data <= rx_data;
                status <= u_wait;
                u_ready <= 1'b1;
            end
        end
    end
endmodule
