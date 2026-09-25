`timescale 1ns/1ps

module tb_alu;

    logic clk;
    logic [31:0] a, b;
    logic [3:0]  alu_op;
    logic [31:0] result;

    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result)
    );

    int errors = 0;

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic apply_op(input logic [31:0] va, vb, input logic [3:0] vop);
        a = va;
        b = vb;
        alu_op = vop;
        @(posedge clk);
    endtask

    task automatic check_op(input logic [31:0] va, vb, input logic [3:0] vop,
                            input logic [31:0] exp_result);
        apply_op(va, vb, vop);
        #1;
        assert (result == exp_result)
            else begin 
                $error("FAIL: a=%0d b=%0d alu_op=%0h got=%0d expected=%0d",
                        va, vb, vop, result, exp_result);
                errors++;
            end
    endtask

    initial begin
        a = 0; b = 0; alu_op = 0;

        // ADD
        check_op(32'd10, 32'd5, 4'b0000, 32'd15);

        // SUB
        check_op(32'd10, 32'd5, 4'b1000, 32'd5);

        // SLL
        check_op(32'd3, 32'd2, 4'b0001, 32'd12);

        // SLT
        check_op(32'hFFFFFFFF, 32'd1, 4'b0010, 32'd1);

        // SLTU
        check_op(32'hFFFFFFFF, 32'd1, 4'b0011, 32'd0);

        // XOR
        check_op(32'hF0F0F0F0, 32'h0F0F0F0F, 4'b0100, 32'hFFFFFFFF);

        // SRL
        check_op(32'h80000000, 32'd1, 4'b0101, 32'h40000000);

        // SRA
        check_op(32'h80000000, 32'd1, 4'b1100, 32'hC0000000);

        // OR
        check_op(32'h00FF00FF, 32'hF0F0F0F0, 4'b0110, 32'hF0FFF0FF);

        // AND
        check_op(32'hFFFF0000, 32'h00FF00FF, 4'b0111, 32'h00FF0000);

        if (errors == 0) begin
            $display("All tests passed!");
            $finish;
        end else begin
            $display("%0d tests failed.", errors);
            $fatal(1);
        end
    end

endmodule