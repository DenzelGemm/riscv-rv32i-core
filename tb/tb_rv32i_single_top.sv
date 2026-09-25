`timescale 1ns/1ps

module tb_rv32i_single_top;

    logic clk;
    logic rst_n;

    function automatic [31:0] enc_i(
        input [6:0] opcode,
        input [2:0] funct3,
        input [4:0] rd,
        input [4:0] rs1,
        input integer imm
    );
        enc_i = {imm[11:0], rs1, funct3, rd, opcode};
    endfunction

    function automatic [31:0] enc_r(
        input [6:0] funct7,
        input [2:0] funct3,
        input [4:0] rd,
        input [4:0] rs1,
        input [4:0] rs2
    );
        enc_r = {funct7, rs2, rs1, funct3, rd, 7'b0110011};
    endfunction

    function automatic [31:0] enc_s(
        input [2:0] funct3,
        input [4:0] rs1,
        input [4:0] rs2,
        input integer imm
    );
        enc_s = {imm[11:5], rs2, rs1, funct3, imm[4:0], 7'b0100011};
    endfunction

    function automatic [31:0] enc_b(
        input [2:0] funct3,
        input [4:0] rs1,
        input [4:0] rs2,
        input integer imm
    );
        enc_b = {imm[12], imm[10:5], rs2, rs1, funct3,
             imm[4:1], imm[11], 7'b1100011};
    endfunction

    function automatic [31:0] enc_u(
        input [6:0] opcode,
        input [4:0] rd,
        input integer imm
    );
        enc_u = {imm[31:12], rd, opcode};
    endfunction

    function automatic [31:0] enc_j(
        input [4:0] rd,
        input integer imm
    );
        enc_j = {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'b1101111};
    endfunction

    rv32i_single_top #(
        .IMEM_INIT_FILE("../../../tb/program.hex")
    ) dut (
        .clk  (clk),
        .rst_n(rst_n)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        #1;
        assert (dut.u_instr_mem.mem[0] == 32'h00500093)
            else $fatal(1, "Instruction ROM was not loaded, got %h", dut.u_instr_mem.mem[0]);

        for (int i = 0; i < 1024; i++) begin
            dut.u_instr_mem.mem[i] = 32'h00000013;
        end

        dut.u_instr_mem.mem[0]  = enc_i(7'b0010011, 3'b000, 5'd1,  5'd0,  5);
        dut.u_instr_mem.mem[1]  = enc_i(7'b0010011, 3'b000, 5'd2,  5'd0,  7);
        dut.u_instr_mem.mem[2]  = enc_r(7'b0000000, 3'b000, 5'd3,  5'd1,  5'd2);
        dut.u_instr_mem.mem[3]  = enc_r(7'b0100000, 3'b000, 5'd4,  5'd2,  5'd1);
        dut.u_instr_mem.mem[4]  = enc_r(7'b0000000, 3'b111, 5'd5,  5'd1,  5'd2);
        dut.u_instr_mem.mem[5]  = enc_r(7'b0000000, 3'b110, 5'd6,  5'd1,  5'd2);
        dut.u_instr_mem.mem[6]  = enc_r(7'b0000000, 3'b100, 5'd7,  5'd1,  5'd2);
        dut.u_instr_mem.mem[7]  = enc_r(7'b0000000, 3'b010, 5'd8,  5'd1,  5'd2);
        dut.u_instr_mem.mem[8]  = enc_i(7'b0010011, 3'b001, 5'd9,  5'd1,  1);
        dut.u_instr_mem.mem[9]  = enc_s(3'b010, 5'd0,  5'd3,  0);
        dut.u_instr_mem.mem[10] = enc_i(7'b0000011, 3'b010, 5'd10, 5'd0,  0);
        dut.u_instr_mem.mem[11] = enc_b(3'b000, 5'd10, 5'd3,  8);
        dut.u_instr_mem.mem[12] = enc_i(7'b0010011, 3'b000, 5'd11, 5'd0, 99);
        dut.u_instr_mem.mem[13] = enc_u(7'b0110111, 5'd12, 32'h12345000);
        dut.u_instr_mem.mem[14] = enc_u(7'b0010111, 5'd13, 32'd0);
        dut.u_instr_mem.mem[15] = enc_j(5'd14, 8);
        dut.u_instr_mem.mem[16] = enc_i(7'b0010011, 3'b000, 5'd15, 5'd0, 99);
        dut.u_instr_mem.mem[17] = enc_i(7'b0010011, 3'b000, 5'd15, 5'd0, 9);
        dut.u_instr_mem.mem[18] = enc_i(7'b0010011, 3'b000, 5'd17, 5'd0, 80);
        dut.u_instr_mem.mem[19] = enc_i(7'b1100111, 3'b000, 5'd16, 5'd17, 0);
        dut.u_instr_mem.mem[20] = enc_i(7'b0010011, 3'b000, 5'd18, 5'd0, 42);
        dut.u_instr_mem.mem[21] = enc_s(3'b010, 5'd0,  5'd18, 4);
        dut.u_instr_mem.mem[22] = enc_i(7'b0010011, 3'b000, 5'd19, 5'd0, 127);
        dut.u_instr_mem.mem[23] = enc_s(3'b000, 5'd0,  5'd19, 8);
        dut.u_instr_mem.mem[24] = enc_i(7'b0000011, 3'b000, 5'd20, 5'd0, 8);
        dut.u_instr_mem.mem[25] = enc_i(7'b0010011, 3'b000, 5'd22, 5'd0, -1);
        dut.u_instr_mem.mem[26] = enc_s(3'b000, 5'd0,  5'd22, 9);
        dut.u_instr_mem.mem[27] = enc_i(7'b0000011, 3'b000, 5'd23, 5'd0, 9);
        dut.u_instr_mem.mem[28] = enc_i(7'b0000011, 3'b100, 5'd24, 5'd0, 9);
        dut.u_instr_mem.mem[29] = enc_i(7'b0010011, 3'b000, 5'd25, 5'd0, 16'h123);
        dut.u_instr_mem.mem[30] = enc_s(3'b001, 5'd0,  5'd25, 10);
        dut.u_instr_mem.mem[31] = enc_i(7'b0000011, 3'b101, 5'd26, 5'd0, 10);
        dut.u_instr_mem.mem[32] = enc_j(5'd0, 0);

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        repeat (40) @(posedge clk);
        #1;

        assert (dut.u_core.u_regfile.regs[1]  == 32'd5)         else $fatal(1, "x1 mismatch: %h",  dut.u_core.u_regfile.regs[1]);
        assert (dut.u_core.u_regfile.regs[2]  == 32'd7)         else $fatal(1, "x2 mismatch: %h",  dut.u_core.u_regfile.regs[2]);
        assert (dut.u_core.u_regfile.regs[3]  == 32'd12)        else $fatal(1, "x3 mismatch: %h",  dut.u_core.u_regfile.regs[3]);
        assert (dut.u_core.u_regfile.regs[4]  == 32'd2)         else $fatal(1, "x4 mismatch: %h",  dut.u_core.u_regfile.regs[4]);
        assert (dut.u_core.u_regfile.regs[5]  == 32'd5)         else $fatal(1, "x5 mismatch: %h",  dut.u_core.u_regfile.regs[5]);
        assert (dut.u_core.u_regfile.regs[6]  == 32'd7)         else $fatal(1, "x6 mismatch: %h",  dut.u_core.u_regfile.regs[6]);
        assert (dut.u_core.u_regfile.regs[7]  == 32'd2)         else $fatal(1, "x7 mismatch: %h",  dut.u_core.u_regfile.regs[7]);
        assert (dut.u_core.u_regfile.regs[8]  == 32'd1)         else $fatal(1, "x8 mismatch: %h",  dut.u_core.u_regfile.regs[8]);
        assert (dut.u_core.u_regfile.regs[9]  == 32'd10)        else $fatal(1, "x9 mismatch: %h",  dut.u_core.u_regfile.regs[9]);
        assert (dut.u_core.u_regfile.regs[10] == 32'd12)        else $fatal(1, "x10 mismatch: %h", dut.u_core.u_regfile.regs[10]);
        assert (dut.u_core.u_regfile.regs[11] == 32'd0)         else $fatal(1, "BEQ did not skip x11 write: %h", dut.u_core.u_regfile.regs[11]);
        assert (dut.u_core.u_regfile.regs[12] == 32'h12345000) else $fatal(1, "x12 mismatch: %h", dut.u_core.u_regfile.regs[12]);
        assert (dut.u_core.u_regfile.regs[13] == 32'd56)        else $fatal(1, "x13 mismatch: %h", dut.u_core.u_regfile.regs[13]);
        assert (dut.u_core.u_regfile.regs[14] == 32'd64)        else $fatal(1, "JAL link mismatch: %h", dut.u_core.u_regfile.regs[14]);
        assert (dut.u_core.u_regfile.regs[15] == 32'd9)         else $fatal(1, "JAL target was not taken: %h", dut.u_core.u_regfile.regs[15]);
        assert (dut.u_core.u_regfile.regs[16] == 32'd80)        else $fatal(1, "JALR link mismatch: %h", dut.u_core.u_regfile.regs[16]);
        assert (dut.u_core.u_regfile.regs[18] == 32'd42)        else $fatal(1, "x18 mismatch: %h", dut.u_core.u_regfile.regs[18]);
        assert (dut.u_core.u_regfile.regs[20] == 32'd127)       else $fatal(1, "LB mismatch: %h", dut.u_core.u_regfile.regs[20]);
        assert (dut.u_core.u_regfile.regs[23] == 32'hFFFFFFFF)  else $fatal(1, "signed LB mismatch: %h", dut.u_core.u_regfile.regs[23]);
        assert (dut.u_core.u_regfile.regs[24] == 32'd255)       else $fatal(1, "LBU mismatch: %h", dut.u_core.u_regfile.regs[24]);
        assert (dut.u_core.u_regfile.regs[26] == 32'h123)       else $fatal(1, "LHU mismatch: %h", dut.u_core.u_regfile.regs[26]);
        assert (dut.u_data_mem.mem[0] == 32'd12)                else $fatal(1, "SW mismatch: %h", dut.u_data_mem.mem[0]);
        assert (dut.u_data_mem.mem[1] == 32'd42)                else $fatal(1, "second SW mismatch: %h", dut.u_data_mem.mem[1]);
        assert (dut.u_data_mem.mem[2][7:0] == 8'h7F)            else $fatal(1, "SB low byte mismatch: %h", dut.u_data_mem.mem[2]);
        assert (dut.u_data_mem.mem[2][15:8] == 8'hFF)           else $fatal(1, "SB signed byte mismatch: %h", dut.u_data_mem.mem[2]);
        assert (dut.u_data_mem.mem[2][31:16] == 16'h0123)      else $fatal(1, "SH mismatch: %h", dut.u_data_mem.mem[2]);
        assert (dut.u_core.pc == 32'd128)                       else $fatal(1, "Expected final loop PC = 128, got %0d", dut.u_core.pc);

        $display("RV32I TOP TEST PASS: ALU, branches, jumps, loads, stores, and writeback verified");
        $finish;
    end

endmodule
