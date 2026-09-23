`timescale 1ns/1ps

module tb_alu;

    logic clk;
    logic [31:0] a, b;
    logic [3:0]  alu_ctrl;
    logic [31:0] result;
    logic        zero;

    alu dut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    int errors = 0;

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic apply_op(input logic [31:0] va, vb, input logic [3:0] vop);
        a = va;
        b = vb;
        alu_ctrl = vop;
        @(posedge clk);
    endtask

    task automatic check_op(input logic [31:0] va, vb, input logic [3:0] vop,
                            input logic [31:0] exp_result, input logic exp_zero);
        apply_op(va, vb, vop);
        #1;
        assert (result == exp_result && zero == exp_zero)
            else begin 
                $error("FAIL: a=%0d b=%0d alu_ctrl=%0h got=%0d/%b expected=%0d/%b",
                        va, vb, vop, result, zero, exp_result, exp_zero);
                errors++;
            end
    endtask

    initial begin
        a = 0; b = 0; alu_ctrl = 0;

        // ADD
        check_op(32'd10, 32'd5, 4'b0000, 32'd15, 1'b0);

        // SUB
        check_op(32'd10, 32'd5, 4'b1000, 32'd5, 1'b0);

        // SLL
        check_op(32'd3, 32'd2, 4'b0001, 32'd12, 1'b0);

        // SLT
        check_op(32'hFFFFFFFF, 32'd1, 4'b0010, 32'd1, 1'b0);

        // SLTU
        check_op(32'hFFFFFFFF, 32'd1, 4'b0011, 32'd0, 1'b1);

        // XOR
        check_op(32'hF0F0F0F0, 32'h0F0F0F0F, 4'b0100, 32'hFFFFFFFF, 1'b0);

        // SRL
        check_op(32'h80000000, 32'd1, 4'b0101, 32'h40000000, 1'b0);

        // SRA
        check_op(32'h80000000, 32'd1, 4'b1100, 32'hC0000000, 1'b0);

        // OR
        check_op(32'h00FF00FF, 32'hF0F0F0F0, 4'b0110, 32'hF0FFF0FF, 1'b0);

        // AND
        check_op(32'hFFFF0000, 32'h00FF00FF, 4'b0111, 32'h00FF0000, 1'b0);

        // Zero check
        check_op(32'd0, 32'd0, 4'b0000, 32'd0, 1'b1);

        if (errors == 0) begin
            $display("All tests passed!");
            $finish;
        end else begin
            $display("%0d tests failed.", errors);
            $fatal(1);
        end
    end

endmodule