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
  
  reg fadd;
  reg fsub;
  reg fmul;
  reg fdiv;
  reg fsw;
  reg flw;
  reg feq;
  reg flt;
  reg fle;
  
  reg fsgnj;
  reg fsgnjn;
  
  wire inval;
  assign inval = ~(lui | auipc | jal | jalr | beq | bne | blt | bge | bltu | bgeu | lb |
            lh | lw | lbu | lhu | sb | sh | sw | addi | slti | sltiu | xori | ori | 
            andi | slli | srli | srai | add | sub | sll | slt | sltu | xor_ | srl |
            sra | or_ | and_ | fadd | fsub | fmul | fdiv | fsw | flw | feq | flt | fle |
            fsgnj | fsgnjn); 
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
    assign funct3 = inst_code[14:12];
    wire [6:0] funct7;
    assign funct7 = inst_code[31:25];

    assign r_type = ((inst_code[6:5] == 2'b01) || inst_code[6:5] == 2'b10) && (inst_code[4:2] == 3'b100);
    wire i_type;
    assign i_type = ((inst_code[6:5] == 2'b00) &&
                        ((inst_code[4:2] == 3'b000) ||
                         (inst_code[4:2] == 3'b100) ||
                         (inst_code[4:2] == 3'b001)))||
                    ((inst_code[6:5] == 2'b11) && (inst_code[4:2] == 3'b001));
    wire s_type;
    assign s_type = (inst_code[6:5] == 2'b01) && ((inst_code[4:2] == 3'b000) || (inst_code[4:2] == 3'b001));
    wire b_type;
    assign b_type = (inst_code[6:5] == 2'b11) && (inst_code[4:2] == 3'b000);
    wire u_type;
    assign u_type = ((inst_code[6:5] == 2'b01) || (inst_code[6:5] == 2'b00)) && (inst_code[4:2] == 3'b101);
    wire j_type;
    assign j_type = ((inst_code[6:5] == 2'b11) && (inst_code[4:2] == 3'b011));

    always @(posedge clk) begin
        rd <= (r_type | i_type | u_type | j_type) ? inst_code[11:7] : 5'd0;
        rs1 <= (r_type | i_type | s_type | b_type) ? inst_code[19:15] : 5'd0;
        rs2 <= (r_type | s_type | b_type) ? inst_code[24:20] : 5'd0;

        imm <= i_type ? {{21{inst_code[31]}}, inst_code[30:20]} :
             s_type ? {{21{inst_code[31]}}, inst_code[30:25], inst_code[11:7]} :
             b_type ? {{20{inst_code[31]}}, inst_code[7], inst_code[30:25], inst_code[11:8], 1'b0} :
             u_type ? {inst_code[31:12], 12'd0} :
             j_type ? {{12{inst_code[31]}}, inst_code[19:12], inst_code[20], inst_code[30:21], 1'b0} : 32'd0;

        inst.lui   <= opcode == 7'b0110111;
        inst.auipc <= opcode == 7'b0010111;
        inst.jal   <= opcode == 7'b1101111;
        inst.jalr  <= opcode == 7'b1100111;

        inst.beq   <= (opcode == 7'b1100011) && (funct3 == 3'b000);
        inst.bne   <= (opcode == 7'b1100011) && (funct3 == 3'b001);
        inst.blt   <= (opcode == 7'b1100011) && (funct3 == 3'b100);
        inst.bge   <= (opcode == 7'b1100011) && (funct3 == 3'b101);
        inst.bltu  <= (opcode == 7'b1100011) && (funct3 == 3'b110);
        inst.bgeu  <= (opcode == 7'b1100011) && (funct3 == 3'b111);

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
        inst.slt  <= (opcode == 7'b0110011) && (funct3 == 3'b010);
        inst.sltu <= (opcode == 7'b0110011) && (funct3 == 3'b011);
        inst.xor_ <= (opcode == 7'b0110011) && (funct3 == 3'b100);
        inst.srl  <= (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
        inst.sra  <= (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
        inst.or_  <= (opcode == 7'b0110011) && (funct3 == 3'b110);
        inst.and_ <= (opcode == 7'b0110011) && (funct3 == 3'b111);
        
        inst.fadd <= (opcode == 7'b1010011) && (funct7 == 7'b0000000);
        inst.fsub <= (opcode == 7'b1010011) && (funct7 == 7'b0000100);
        inst.fmul <= (opcode == 7'b1010011) && (funct7 == 7'b0001000);
        inst.fdiv <= (opcode == 7'b1010011) && (funct7 == 7'b0001100);
        inst.feq  <= (opcode == 7'b1010011) && (funct7 == 7'b1010000) && (funct3 == 3'b010);
        inst.flt  <= (opcode == 7'b1010011) && (funct7 == 7'b1010000) && (funct3 == 3'b001);
        inst.fle  <= (opcode == 7'b1010011) && (funct7 == 7'b1010000) && (funct3 == 3'b000);
        inst.fsgnj   <= (opcode == 7'b1010011) && (funct7 == 7'b0010000) && (funct3 == 3'b000);
        inst.fsgnjn  <= (opcode == 7'b1010011) && (funct7 == 7'b0010000) && (funct3 == 3'b001);
        
        inst.fsw <= opcode == 7'b0100111;
        inst.flw <= opcode == 7'b0000111;
    end
endmodule


typedef enum reg [2:0] {
    s_wait, s_inst_fetch, s_inst_decode, s_inst_write, s_inst_exec, s_inst_inval, s_inst_mem
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
    
    assign rs1 = rs1_idx == 0 ? 32'd0 : iregs[rs1_idx];
    assign rs2 = rs2_idx == 0 ? 32'd0 : iregs[rs2_idx];
    
    assign iregs[0] = 32'd0;
    
    generate
        genvar i;
        for (i = 1; i < 32; i = i + 1) begin
            always @(posedge clk) begin
                if (~rstn) begin
                    iregs[i] <= 32'd0;
                end else begin 
                    if (rd_enable && i == rd_idx) begin
                        iregs[i] <=  data;
                    end
                end
            end
        end
    endgenerate

endmodule

module fregister
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
    reg [31:0] fregs[32];
    
    assign rs1 = fregs[rs1_idx];
    assign rs2 = fregs[rs2_idx];
    
    generate
        genvar i;
        for (i = 0; i < 32; i = i + 1) begin
            always @(posedge clk) begin
                if (~rstn) begin
                    fregs[i] <= 32'd0;
                end else begin 
                    if (rd_enable && i == rd_idx) begin
                        fregs[i] <=  data;
                    end
                end
            end
        end
    endgenerate

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
            result <= 32'd0;
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
    (
    input wire clk,
    input wire rstn,
    
    input reg [31:0] _instr,
    output reg [31:0] pc,
    output reg [3:0] instr_we,
    output reg [31:0] _instr_in,
    

    output reg [31:0] _din,
    output reg [31:0] addr,
    input reg [31:0] _dout,
    output reg [3:0]data_we,
    
    input wire memory_done,
    output wire load

    );
    // endian
    wire [31:0] instr;
    assign instr = {_instr[7:0], _instr[15:8], _instr[23:16], _instr[31:24]};
    reg [31:0] instr_in;
    assign _instr_in = {instr_in[7:0], instr_in[15:8], instr_in[23:16], instr_in[31:24]};
    reg [31:0] din;
    assign _din = {din[7:0], din[15:8], din[23:16], din[31:24]};
    wire [31:0] dout;
    assign dout = {_dout[7:0], _dout[15:8], _dout[23:16], _dout[31:24]};


    reg [33:0] clock_counter = 34'd0;
    (* mark_debug = "true" *) wire [33:0] clock_counter_debug;
    assign clock_counter_debug = clock_counter;
    (* mark_debug = "true" *) wire [31:0] pc_debug;
    assign pc_debug = pc;
    reg [31:0] debug_status_register = 32'd0;
    reg [31:0] instruction = 32'd0;

    s_inst state = s_wait;
    
    reg wait_for_memory;

    reg [31:0] fregs[32];

    localparam ds_illegal_inst = 32'b1;
    localparam ds_illegal_state = 32'b10;

    // TODO: reduce imms to one regs
    instif inst();
    reg [4:0] rd;
    reg rd_enable;
    reg frd_enable;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [31:0] imm;
    reg [31:0] src1;
    reg [31:0] src2;
    reg [31:0] fsrc1;
    reg [31:0] fsrc2;

    reg [31:0] result;
    reg [31:0] alu_result;
    reg [31:0] load_result;
    reg [31:0] fpu_result;
    
    wire [31:0] alu_src1;
    wire [31:0] alu_src2;

    decoder DECODER(.clk(clk), .rstn(rstn), .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm), .inst(inst), .inst_code(instr));
    register REGISTER(.clk(clk), .rstn(rstn), .rd_idx(rd), .rd_enable(rd_enable), .rs1_idx(rs1), .rs2_idx(rs2), .data(result), .rs1(src1), .rs2(src2));
    fregister FREGISTER(.clk(clk), .rstn(rstn), .rd_idx(rd), .rd_enable(frd_enable), .rs1_idx(rs1), .rs2_idx(rs2), .data(result), .rs1(fsrc1), .rs2(fsrc2));
    
    alu ALU(.clk(clk), .rstn(rstn), .src1(alu_src1), .src2(alu_src2), .result(alu_result), .inst(inst));
    fpu FPU(.clk(clk), .rstn(rstn), .src1(fsrc1), .src2(fsrc2), .result(fpu_result), .inst(inst));
    
    assign alu_src1 = src1;
    assign alu_src2 = (inst.add | inst.sub | inst.sll | inst.slt | inst.sltu | inst.xor_ | inst.srl | inst.sra  | inst.or_  | inst.and_ |
                       inst.beq | inst.bne | inst.blt | inst.bge | inst.bltu | inst.bgeu) ? src2 :
                       imm;
                       
    reg load_r;
    assign load = load_r;
    
    always @(posedge clk) begin
        if (~rstn) begin 
        end else if (state == s_inst_exec) begin
            load_r <= inst.lb | inst.lh | inst.lw | inst.lbu | inst.lhu | inst.flw;
        end else begin
            load_r <= 1'b0;
        end
    end
    
    always @(posedge clk) begin
        if (~rstn) begin 
            result <= 32'd0;
            rd_enable <= 1'b0;
        end else if (state != s_inst_write) begin
            rd_enable <= 1'b0;
            frd_enable <= 1'b0;
        end else if (inst.lui) begin
            result <= imm;
            rd_enable <= 1'b1;
        end else if (inst.auipc) begin
            result <= pc + imm;
            rd_enable <= 1'b1;
        end else if (inst.addi | inst.slti | inst.xori | inst.ori | inst.andi | inst.slli | inst.srli | inst.srai | inst.add | inst.sub | inst.sll
                            | inst.slt | inst.sltu | inst.xor_ | inst.srl | inst.sra  | inst.or_  | inst.and_) begin
            result <= alu_result;
            rd_enable <= 1'b1;
        end else if (inst.lb | inst.lh | inst.lw | inst.lbu | inst.lhu) begin
            result <= load_result;
            rd_enable <= 1'b1;
        end else if (inst.jal | inst.jalr) begin
            result <= pc + 32'd4;
            rd_enable <= 1'b1;
        end else if (inst.feq | inst.fle | inst.flt) begin
            result <= fpu_result;
            rd_enable <= 1'b1;
        end else if (inst.fadd | inst.fsub | inst.fmul | inst.fdiv | inst.fsgnj | inst.fsgnjn) begin
            result <= fpu_result;
            frd_enable <= 1'b1;
        end else if (inst.flw) begin
            result <= load_result;
            frd_enable <= 1'b1;
        end else begin
            result <= 32'd0;
        end
    end
        
    // update pc
    always @(posedge clk) begin 
        if (~rstn) begin
            pc <= 32'd0;
        end else if (state == s_inst_write) begin
            if (inst.jalr) begin
                pc <= src1 + imm;
            end else if (inst.jal) begin
                pc <= pc + imm;
            end else if (inst.beq | inst.bne | inst.blt | inst.bge | inst.bltu | inst.bgeu) begin
                if (alu_result == 32'd0) begin
                    pc <= pc + 32'd4;
                end else begin
                    pc <= pc + imm;
                end
            end else begin
                pc <= pc + 32'd4;
            end
        end else begin
        end
    end
       
    // load/store
    assign addr = src1 + imm;   
    always @(posedge clk) begin
        //addr <= src1 + imm;
        if (~rstn) begin
            load_result <= 32'd0;
            din <= 32'd0;
            data_we <= 4'b0;
        end else if (state == s_inst_exec) begin
            if (inst.sb) begin
                din <= src2;
                data_we <= 4'b0001;
            end else if (inst.sh) begin
                din <= src2;
                data_we <= 4'b0011;
            end else if (inst.sw) begin
                din <= src2;
                data_we <= 4'b1111;
            end else if (inst.fsw) begin
                din <= fsrc2;
                data_we <= 4'b1111;
            end
        end else if (state == s_inst_mem) begin    
            data_we <= 4'b0000;
            if (inst.lb) begin
                //load_result <= {{25{dout[7]}}, dout[6:0]};  
                load_result <= {24'd0, dout[7:0]};  
            end else if (inst.lh) begin
                load_result <= {16'd0, dout[15:0]};
            end else if (inst.lw) begin
                load_result <= dout;
            end else if (inst.flw) begin
                load_result <= dout;
            end
        end else if (state != s_inst_exec) begin
            data_we <= 4'b0000;
        end
    end
    
    always @(posedge clk) begin
        if (~rstn) begin
            clock_counter <= 34'd0;
            state <= s_wait;
            debug_status_register <= 34'b0;
            instr_we <= 1'd0;
            wait_for_memory <= 1'b0;
        end else begin
           
            if (inst.inval) begin
                state <= s_inst_inval;
            end else if (state == s_wait) begin
                state <= s_inst_fetch;
            end else if (state == s_inst_fetch) begin
                 clock_counter <= clock_counter + 34'd1;
                state <= s_inst_decode;
            end else if (state == s_inst_decode) begin
                state <= s_inst_exec;
            end else if (state == s_inst_exec) begin
                if (inst.lb | inst.lh | inst.lw | inst.sb | inst.sh | inst.sw | inst.flw | inst.fsw) begin
                    state <= s_inst_mem;
                end else begin
                    state <= s_inst_write;
                end
            end else if (state == s_inst_mem) begin
                if (wait_for_memory) begin
                    if (memory_done) begin
                        wait_for_memory <= 1'b0;
                        state <= s_inst_write;
                    end
                end else begin
                    wait_for_memory <= 1'b1;
                end
            end else if (state == s_inst_write) begin
                state <= s_inst_fetch;
            end else begin
                debug_status_register <= debug_status_register | ds_illegal_state;
            end
        end
    end
endmodule

