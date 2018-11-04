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

typedef enum reg [2:0] {
    map_uart_wait, map_uart_receive_wait, map_uart_receive, map_uart_transmit, map_uart_transmit_wait
} map_uart;


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
    
    // to uart  
    input  wire ready,
    input  wire [7:0]r_data,
    output reg [7:0]t_data,
    output reg t_valid,
    output reg r_valid,
    input tx_done,
    input rx_done,
 
    // from/to core
    input wire [31:0] c_din,
    input wire [31:0] c_addr,
    input wire [3:0] c_write_enable,
    output wire [31:0] c_dout,
    output reg done,
    input wire load
    );
    
    reg [31:0] din_reg;
    reg [31:0] addr_reg;
    reg [3:0] write_enable_reg;
    reg [31:0] c_dout_reg;
    reg [7:0] led_reg;
    
    map_uart state;
    
    parameter uart_rx_addr = 32'h10000;
    parameter uart_tx_addr = 32'h10004;    
    parameter led_addr = 32'h10008;
    
    wire is_io;
    assign is_io = ((c_addr >> 12) == 32'h10);
    
    wire [7:0]b_data;
    assign b_data =  c_din[31:24];
    
    
    
    assign led          = c_write_enable && (c_addr == led_addr) ? b_data : led_reg;
    assign addr         = is_io ? addr_reg : c_addr;
    assign write_enable = is_io ? write_enable_reg : c_write_enable;
    assign din          = is_io ? din_reg : c_din;
    assign c_dout       = is_io ? c_dout_reg : dout;

    always @(posedge clk) begin
        if (~rstn) begin
            led_reg <= 8'd0;
            addr_reg <= 32'd0;
            write_enable_reg <= 4'd0;
            c_dout_reg <= 32'd0;
            din_reg <= 32'd0;
            done <= 1'b0;
            t_valid <= 1'b0;
            r_valid <= 1'b0;
            t_data <= 8'b0;
            state <= map_uart_wait;
        end else begin
            if (state == map_uart_wait) begin
                led_reg <= led;
                addr_reg <= addr;
                write_enable_reg <= write_enable;
                din_reg <= din;
                c_dout_reg <= c_dout;
            
                // uart receive
                if ((c_addr == uart_rx_addr) && load) begin
                    state <= map_uart_receive_wait;
                    done <= 1'b0;
                end else if ((c_addr == uart_tx_addr) && c_write_enable[0]) begin
                    state <= map_uart_transmit_wait;
                    done <= 1'b0;
                end else begin
                    done <= 1'b1;
                end
            end else if (state == map_uart_receive_wait) begin
                if (ready) begin
                    r_valid <= 1'b1;
                    state <= map_uart_receive;
                end
            end else if (state == map_uart_receive) begin
                r_valid <= 1'b0;
                if (rx_done) begin
                    c_dout_reg <= {r_data, 24'b0};
                    state <= map_uart_wait;
                    done <= 1'b1;
                end
            end else if (state == map_uart_transmit_wait) begin
                if (ready) begin
                    t_valid <= 1'b1;
                    state <= map_uart_transmit;
                    t_data <= b_data;
                end
            end else if (state == map_uart_transmit) begin 
                t_valid <= 1'b0;
                if (tx_done) begin
                    state <= map_uart_wait;
                    done <= 1'b1;
                end
            end
        end 
    end
    
endmodule
