`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/04 20:58:19
// Design Name: 
// Module Name: fcomp
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


module feq(
    wire [31:0] x,
    wire [31:0] y,
    wire z
);
    assign z = x == y ? 1'b1 : 1'b0;
endmodule

module flt(
    wire [31:0] x,
    wire [31:0] y,
    wire z
);
	wire s1;
    wire s2;
    wire [7:0] e1;
    wire [7:0] e2;
    wire [22:0] m1;
    wire [22:0] m2;
    assign {s1,e1,m1} = x;
    assign {s2,e2,m2} = y;
    
    assign z = (s1 == 1'b1) && (s2 == 1'b0) ? 1'b1 :
               (s1 == 1'b0) && (e1 < e2) ? 1'b1 :
               (s1 == 1'b0) && (e1 == e2) && (m1 < m2) ? 1'b1 :
               (s1 == 1'b1) && (e1 > e2) ? 1'b1 :
               (s1 == 1'b1) && (e1 == e2) && (m1 > m2) ? 1'b1 :
               1'b0;
endmodule

module fle(
    wire [31:0] x,
    wire [31:0] y,
    wire z
);
    wire t;
    flt FLT(x, y, t);
    assign z = t;
endmodule
