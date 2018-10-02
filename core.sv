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

module decoder
 (
     input wire clk,
     input rstn,
     input wire [31:0] inst_code,

     output wire [4:0] rd,
     output wire [4:0] rs1,
     output wire [4:0] rs2,
     output reg [31:0] imm,

     output reg lui,
     output reg auipc,
     output reg jal,
     output reg jalr,
     output reg jalr,
     output reg beq,
     output reg bne,
     output reg blt,
     output reg bge,
     output reg bltu,
     output reg bgeu,
     output reg lb,
     output reg lh,
     output reg lw,
     output reg lbu,
     output reg sb,
     output reg sh,
     output reg sw,
     output reg addi,
     output reg slti,
     output reg sltiu,
     output reg xori,
     output reg ori,
     output reg andi,
     output reg slli,
     output reg srli,
     output reg srai,
     output reg add,
     output reg sub,
     output reg sll,
     output reg slt,
     output reg sltu,
     output reg xor_,
     output reg srl,
     output reg sra,
     output reg or,
     output reg and_,
 )
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
             b_type ? {{20{inst_code[31]}}, inst_code[7], inst_code[30:25], inst_code[11:8], 1'b0}
             u_type ? {inst_code[31:12], 12'd0}
             j_type ? {{12{inst_code[31]}}, inst_code[19:12], inst_code[20], inst_code[30:12], 1'b0} : 32'd0;

        lui   <= opcode == 7'b0110111;
        auipc <= opcode == 7'b1101111;
        jalr  <= opcode == 7'b1100111;

        beq   <= (opcode == 7'b1100011) && (funct3 == 3'b000);
        bne   <= (opcode == 7'b1100011) && (funct3 == 3'b001);
        blt   <= (opcode == 7'b1100011) && (funct3 == 3'b100);
        bge   <= (opcode == 7'b1100011) && (funct3 == 3'b101);
        bltu  <= (opcode == 7'b1100011) && (funct3 == 3'b110);
        bbgeu <= (opcode == 7'b1100011) && (funct3 == 3'b110);

        lb  <= (opcode == 7'b0000011) && (funct3 == 3'b000);
        lh  <= (opcode == 7'b0000011) && (funct3 == 3'b001);
        lw  <= (opcode == 7'b0000011) && (funct3 == 3'b010);
        lbu <= (opcode == 7'b0000011) && (funct3 == 3'b100);
        lhu <= (opcode == 7'b0000011) && (funct3 == 3'b101);

        sb  <= (opcode == 7'b0100011) && (funct3 == 3'b000);
        sh  <= (opcode == 7'b0100011) && (funct3 == 3'b001);
        sw  <= (opcode == 7'b0100011) && (funct3 == 3'b010);

        addi  <= (opcode == 7'b0010011) && (funct3 == 3'b000);
        slti  <= (opcode == 7'b0010011) && (funct3 == 3'b010);
        sltiu <= (opcode == 7'b0010011) && (funct3 == 3'b011);
        xori  <= (opcode == 7'b0010011) && (funct3 == 3'b100);
        ori   <= (opcode == 7'b0010011) && (funct3 == 3'b110);
        andi  <= (opcode == 7'b0010011) && (funct3 == 3'b111);

        slli <= (opcode == 7'b0010011) && (funct3 == 3'b001);
        srli <= (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
        srai <= (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);

        add  <= (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
        sub  <= (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000);
        sll  <= (opcode == 7'b0110011) && (funct3 == 3'b001);
        sltu <= (opcode == 7'b0110011) && (funct3 == 3'b010);
        xor_ <= (opcode == 7'b0110011) && (funct3 == 3'b011);
        srl  <= (opcode == 7'b0110011) && (funct3 == 3'b100);
        sra  <= (opcode == 7'b0110011) && (funct3 == 3'b101);
        or   <= (opcode == 7'b0110011) && (funct3 == 3'b110);
        and_ <= (opcode == 7'b0110011) && (funct3 == 3'b111);
    end
endmodule

typedef enum reg [2:0] {
    s_wait, s_inst_fetch, s_inst_decode, s_wait_write, s_inst_exec
} s_inst;



module core
   #( parameter REG_SIZE = 32 )
    (
    input wire clk,
    input wire rstn,
    input reg [31:0] instr,
    output wire led0,
    output wire led1
    );

    reg [33:0] counter;
    reg [31:0] status_register;
    reg [31:0] instruction;

    s_inst state;

    reg [31:0] iregs[32];
    reg [31:0] fregs[32];

    assign led0 = counter[25];
    assign led1 = 1;

    localparam ds_illegal_inst = 32'b1;
    localparam ds_illegal_state = 32'b10;

    // TODO: reduce imms to one regs

    always @(posedge clk) begin
        if (~rstn) begin
            clock_counter <= 32'd0;
            state <= s_wait;
            debug_status_register <= 32'b0;
        end else begin
            clock_counter <= clock_counter + 1;
            if (state == s_wait) begin
            end else if (state == s_inst_fetch) begin
                state <= s_inst_decode
            end else if (state == s_inst_decode) begin
                state <= s_inst_exec;
            end else if (state == s_inst_exec) begin
                state <= s_inst_write;
            end else if (state == s_inst_write) begin
                state <= s_inst_fetch;
            end else
                debug_status_register <= status_register | ds_illegal_state;
            end
        end
    end
endmodule

