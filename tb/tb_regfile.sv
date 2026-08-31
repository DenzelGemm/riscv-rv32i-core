`timescale 1ns/1ps

module tb_regfile;

    int errors = 0;

    logic clk;
    logic rst_n;
    logic we;
    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rd_data;
    logic [31:0] rs1_data, rs2_data;

    logic [31:0] exp_regs [0:31];

    regfile dut (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .we(we),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_eq(input string msg, input logic [31:0] got, input logic [31:0] exp);
        if (got !== exp) begin
            errors++;
            $error("%s: got=%0h expected=%0h", msg, got, exp);
        end
    endtask

    task automatic write_reg(input logic [4:0] addr, input logic [31:0] data);
        rd_addr = addr;
        rd_data = data;
        we = 1'b1;

        if (addr != 5'd0)
            exp_regs[addr] = data;

        @(posedge clk);
        #1;
        we = 1'b0;
    endtask

    task automatic read_check(input logic [4:0] a1, input logic [4:0] a2,
                              input logic [31:0] exp1, input logic [31:0] exp2);
        rs1_addr = a1;
        rs2_addr = a2;
        #1;

        check_eq($sformatf("rs1[%0d]", a1), rs1_data, exp1);
        check_eq($sformatf("rs2[%0d]", a2), rs2_data, exp2);
    endtask

    initial begin
        integer i;

        for (i = 0; i < 32; i++)
            exp_regs[i] = 32'd0;

        rst_n = 0;
        we = 1'b0;
        rs1_addr = 5'd0;
        rs2_addr = 5'd0;
        rd_addr = 5'd0;
        rd_data = 32'd0;

        #10;
        rst_n = 1;

        write_reg(5'd1, 32'h11111111);
        read_check(5'd1, 5'd1, 32'h11111111, 32'h11111111);

        write_reg(5'd2, 32'h22222222);
        read_check(5'd1, 5'd2, 32'h11111111, 32'h22222222);

        write_reg(5'd0, 32'hDEADBEEF);
        read_check(5'd0, 5'd0, 32'd0, 32'd0);

        rst_n = 0;
        @(posedge clk);

        read_check(5'd1, 5'd2, 32'd0, 32'd0);

        if (errors == 0) begin
            $display("PASS: regfile tests passed");
            $finish;
        end else begin
            $error("FAILED: %0d errors", errors);
            $fatal(1, "REGFILE TEST FAILED");
        end
    end

endmodule