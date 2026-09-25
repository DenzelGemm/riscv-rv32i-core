`timescale 1ns/1ps

module tb_rv32i_top;

    logic clk;
    logic rst_n;

    rv32i_top #(
        .IMEM_INIT_FILE("tb/program.hex")
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

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        repeat (4) @(posedge clk);
        #1;

        assert (dut.u_data_mem.mem[0] == 32'd8)
            else $fatal(1, "Expected data_mem[0] = 8, got %0d", dut.u_data_mem.mem[0]);

        $display("RV32I TOP TEST PASS: data_mem[0] = %0d", dut.u_data_mem.mem[0]);
        $finish;
    end

endmodule
