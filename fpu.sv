`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/04 19:31:36
// Design Name: 
// Module Name: fpu
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


module fpu(
    input wire clk,
    input wire rstn,
    input wire [31:0] src1,
    input wire [31:0] src2,
    output wire [31:0] result,
    output wire ovf,
    instif inst
    );
    wire [31:0]fadd_result;
    wire fadd_ovf;
    wire [31:0]fsub_result;
    wire fsub_ovf;
    wire [31:0]fmul_result;
    wire fmul_ovf;
    wire [31:0]fdiv_result;
    wire fdiv_ovf;
    
    wire feq_result;
    wire flt_result;
    wire fle_result;
    
    fadd FADD(src1, src2, fadd_result, fadd_ovf);
    fsub FSUB(src1, src2, fsub_result, fsub_ovf);
    fmul FMUL(src1, src2, fmul_result, fmul_ovf);
    fdiv FDIV(src1, src2, fdiv_result, fdiv_ovf);
    
    feq FEQ(src1, src2, feq_result);
    flt FLT(src1, src2, flt_result);
    fle FLE(src1, src2, fle_result);
    
    assign result = inst.fadd ? fadd_result :
                    inst.fsub ? fsub_result :
                    inst.fmul ? fmul_result :
                    inst.fdiv ? fdiv_result :
                    inst.feq ? {31'b0, feq_result} :
                    inst.flt ? {31'b0, flt_result} :
                    inst.fle ? {31'b0, fle_result} :
                    32'd0;
    assign ovf = inst.fadd ? fadd_ovf :
                 inst.fsub ? fsub_ovf :
                 inst.fmul ? fmul_ovf :
                 inst.fdiv ? fdiv_ovf :
                 1'b0;

endmodule
