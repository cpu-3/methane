`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IS
// Engineer: moratorium08
//
// Create Date: 2018/09/28 17:26:19
// Design Name: methane
// Module Name: core
// Project Name: methane
// Target Devices: KCU105
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

interface instif;
  reg lui;
  reg auipc;
  reg jal;
  reg jalr;
  reg beq;
  reg bne;
  reg blt;
  reg bge;
  reg bltu;
  reg bgeu;
  reg bbgeu;
  reg lb;
  reg lh;
  reg lw;
  reg lbu;
  reg lhu;
  reg sb;
  reg sh;
  reg sw;
  reg addi;
  reg slti;
  reg sltiu;
  reg xori;
  reg ori;
  reg andi;
  reg slli;
  reg srli;
  reg srai;
  reg add;
  reg sub;
  reg sll;
  reg slt;
  reg sltu;
  reg xor_;
  reg srl;
  reg sra;
  reg or_;
  reg and_;
endinterface

module decoder
 (
     input wire clk,
     input rstn,

     output reg [4:0] rd,
     output reg [4:0] rs1,
     output reg [4:0] rs2,
     output reg [31:0] imm,

     instif inst,
     
     input reg [31:0] inst_code
 );
    wire r_type;
    wire [6:0] opcode;
    assign opcode = inst_code[6:0];
    wire [2:0] funct3;
    assign funct3 = inst_code[2:0];
    wire [6:0] funct7;
    assign funct7 = inst_code[6:0];

    assign r_type = (inst_code[6:5] == 2'b01) && (inst_code[4:2] == 3'b100);
    wire i_type;
    assign i_type = ((inst_code[6:5] == 2'b00) &&
                        ((inst_code[4:2] == 3'b000) ||
                         (inst_code[4:2] == 3'b100))) ||
                    ((inst_code[6:5] == 2'b11) && (inst_code[4:2] == 3'b001));
    wire s_type;
    assign s_type = (inst_code[6:5] == 2'b01) && (inst_code[4:2] == 3'b000);
    wire b_type;
    assign b_type = (inst_code[6:5] == 2'b11) && (inst_code[4:2] == 3'b000);
    wire u_type;
    assign u_type = ((inst_code[6:5] == 2'b01) || (inst_code[6:5] == 2'b00)) && (inst_code[4:2] == 3'b101);
    wire j_type;
    assign j_type = ((inst_code[6:5] == 2'b01) || (inst_code[6:5] == 2'b00)) && (inst_code[4:2] == 3'b101);

    always @(posedge clk) begin
        rd <= (r_type | i_type | u_type | j_type) ? inst_code[11:7] : 5'd0;
        rs1 <= (r_type | i_type | s_type | b_type) ? inst_code[19:15] : 5'd0;
        rs2 <= (r_type | s_type | b_type) ? inst_code[24:20] : 5'd0;

        imm <= i_type ? {{21{inst_code[31]}}, inst_code[30:20]} :
             s_type ? {{21{inst_code[31]}}, inst_code[30:25], inst_code[11:7]} :
             b_type ? {{20{inst_code[31]}}, inst_code[7], inst_code[30:25], inst_code[11:8], 1'b0} :
             u_type ? {inst_code[31:12], 12'd0} :
             j_type ? {{12{inst_code[31]}}, inst_code[19:12], inst_code[20], inst_code[30:12], 1'b0} : 32'd0;

        inst.lui   <= opcode == 7'b0110111;
        inst.auipc <= opcode == 7'b1101111;
        inst.jal   <= opcode == 7'b1101111;
        inst.jalr  <= opcode == 7'b1100111;

        inst.beq   <= (opcode == 7'b1100011) && (funct3 == 3'b000);
        inst.bne   <= (opcode == 7'b1100011) && (funct3 == 3'b001);
        inst.blt   <= (opcode == 7'b1100011) && (funct3 == 3'b100);
        inst.bge   <= (opcode == 7'b1100011) && (funct3 == 3'b101);
        inst.bltu  <= (opcode == 7'b1100011) && (funct3 == 3'b110);
        inst.bbgeu <= (opcode == 7'b1100011) && (funct3 == 3'b110);

        inst.lb  <= (opcode == 7'b0000011) && (funct3 == 3'b000);
        inst.lh  <= (opcode == 7'b0000011) && (funct3 == 3'b001);
        inst.lw  <= (opcode == 7'b0000011) && (funct3 == 3'b010);
        inst.lbu <= (opcode == 7'b0000011) && (funct3 == 3'b100);
        inst.lhu <= (opcode == 7'b0000011) && (funct3 == 3'b101);

        inst.sb  <= (opcode == 7'b0100011) && (funct3 == 3'b000);
        inst.sh  <= (opcode == 7'b0100011) && (funct3 == 3'b001);
        inst.sw  <= (opcode == 7'b0100011) && (funct3 == 3'b010);

        inst.addi  <= (opcode == 7'b0010011) && (funct3 == 3'b000);
        inst.slti  <= (opcode == 7'b0010011) && (funct3 == 3'b010);
        inst.sltiu <= (opcode == 7'b0010011) && (funct3 == 3'b011);
        inst.xori  <= (opcode == 7'b0010011) && (funct3 == 3'b100);
        inst.ori   <= (opcode == 7'b0010011) && (funct3 == 3'b110);
        inst.andi  <= (opcode == 7'b0010011) && (funct3 == 3'b111);

        inst.slli <= (opcode == 7'b0010011) && (funct3 == 3'b001);
        inst.srli <= (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
        inst.srai <= (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);

        inst.add  <= (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
        inst.sub  <= (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000);
        inst.sll  <= (opcode == 7'b0110011) && (funct3 == 3'b001);
        inst.sltu <= (opcode == 7'b0110011) && (funct3 == 3'b010);
        inst.xor_ <= (opcode == 7'b0110011) && (funct3 == 3'b011);
        inst.srl  <= (opcode == 7'b0110011) && (funct3 == 3'b100);
        inst.sra  <= (opcode == 7'b0110011) && (funct3 == 3'b101);
        inst.or_   <= (opcode == 7'b0110011) && (funct3 == 3'b110);
        inst.and_ <= (opcode == 7'b0110011) && (funct3 == 3'b111);
    end
endmodule


typedef enum reg [2:0] {
    s_wait, s_inst_fetch, s_inst_decode, s_inst_write, s_inst_exec
} s_inst;

typedef enum reg [4:0] {
    s_alu_add, s_alu_sub, s_alu_xor, s_alu_shl, s_alu_shr, s_alu_eq, s_alu_lts, s_alu_ltu, s_alu_or, s_alu_and
} s_alu;


module register
    (
        input wire clk,
        input wire rstn,
        
        input wire [4:0] rd_idx,
        input wire rd_enable,
        input wire [31:0] data,
        
        input wire [4:0] rs1_idx,
        output reg [31:0] rs1,
        input wire [4:0] rs2_idx,
        output reg [31:0] rs2
    );
    reg [31:0] iregs[32];
 
    always @(posedge clk) begin
        if (~rstn) begin
            iregs[0] <= 32'd0;
            iregs[1] <= 32'd0;
            iregs[2] <= 32'd0;
            iregs[3] <= 32'd0;
            iregs[4] <= 32'd0;
        end else begin            
            rs1 <= iregs[rs1_idx];
            rs2 <= iregs[rs2_idx];
            if (rd_enable) begin
                iregs[rs1_idx] <= data;
            end
        end
    end
endmodule

module alu 
 (
    input wire clk,
    input wire rstn,
    input wire [31:0] src1,
    input wire [31:0] src2,
    output reg [31:0] result,
    instif inst
 );
    always @(posedge clk) begin
        if (~rstn) begin
        end else begin
            result <= (inst.add | inst.addi) ? src1 + src2 : 
                      (inst.sub)             ? src1 - src2 :
                      (inst.slti | inst.slt) ? $signed(src1) < $signed(src2) :
                      (inst.sltiu | inst.sltu) ? src1 < src2 :
                      (inst.xori | inst.xor_) ? src1 ^ src2:
                      (inst.ori | inst.or_) ? src1 | src2:
                      (inst.andi | inst.and_) ? src1 & src2:
                      (inst.slli | inst.sll) ? src1 << src2:
                      (inst.srli | inst.srl) ? src1 >> src2:
                      (inst.srai | inst.sra) ? $signed(src1) >>> $signed(src2):
                      (inst.beq) ? src1 == src2:
                      (inst.bne) ? src1 != src2:
                      (inst.blt) ? $signed(src1) < $signed(src2):
                      (inst.bge) ? $signed(src1) >= $signed(src2):
                      (inst.bltu) ? src1 < src2:
                      (inst.bgeu) ? src1 >= src2:
                      32'd0;
        end
    end 
endmodule

module core
   #( parameter REG_SIZE = 32 )
    (
    input wire clk,
    input wire rstn,
    output wire led0,
    output wire led1,
    
    input reg [31:0] instr,
    output reg [31:0] pc,
    output reg [3:0]instr_we,
    output reg [31:0]instr_in,
    

    output reg [31:0] din,
    output reg [31:0] addr,
    input reg [31:0] dout,
    output reg [3:0]data_we

    );

    reg [33:0] clock_counter = 34'd0;
    reg [31:0] debug_status_register = 32'd0;
    reg [31:0] instruction = 32'd0;

    s_inst state = s_wait;

    reg [31:0] fregs[32];

    assign led0 = clock_counter[25];
    assign led1 = 1;

    localparam ds_illegal_inst = 32'b1;
    localparam ds_illegal_state = 32'b10;

    // TODO: reduce imms to one regs
    instif inst();
    reg [4:0] rd;
    reg rd_enable;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [31:0] imm;
    reg [31:0] src1;
    reg [31:0] src2;
    reg [31:0] result;
    reg [31:0] alu_result;
    
    decoder DECODER(.clk(clk), .rstn(rstn), .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm), .inst(inst));
    register REGISTER(.clk(clk), .rstn(rstn), .rd_idx(rd), .rd_enable(rd_enable), .rs1_idx(rs1), .rs2_idx(rs2), .data(result), .rs1(src1), .rs2(src2));
    alu ALU(.clk(clk), .rstn(rstn), .src1(src1), .src2(src2), .result(alu_result), .inst(inst));
    // counts up clock and changes state
    
    assign result = inst.lui ? (imm << 12) : 
                    inst.auipc ? (pc + (imm << 12)) :
                    (inst.addi | inst.slti | inst.xori | inst.ori | inst.andi | inst.slli | inst.srli | inst.srai | inst.add | inst.sub | inst.sll
                    | inst.slt | inst.sltu | inst.xor_ | inst.srl | inst.sra  | inst.or_  | inst.and_) ? alu_result : 32'd0;
    
    // update pc
    always @(posedge clk) begin 
        if (~rstn) begin
            pc <= 32'd0;
        end else if (state == s_inst_exec) begin
            if (inst.jalr) begin
                pc <= pc + src1;
            end else if (inst.jal) begin
                pc <= pc + imm;
            end else begin
                pc <= 32'd4;
            end
        end else begin
        end
    end
    
    always @(posedge clk) begin
        if (~rstn) begin
            clock_counter <= 32'd0;
            state <= s_wait;
            debug_status_register <= 32'b0;
            instr_we <= 1'd0;
            data_we <= 1'd0;
            addr <= 32'd0;
            dout <= 32'd0;
        end else begin
            clock_counter <= clock_counter + 1;
            if (state == s_wait) begin
            end else if (state == s_inst_fetch) begin
                state <= s_inst_decode;
            end else if (state == s_inst_decode) begin
                state <= s_inst_exec;
            end else if (state == s_inst_exec) begin
                state <= s_inst_write;
            end else if (state == s_inst_write) begin
                state <= s_inst_fetch;
            end else begin
                debug_status_register <= debug_status_register | ds_illegal_state;
            end
        end
    end
endmodule

