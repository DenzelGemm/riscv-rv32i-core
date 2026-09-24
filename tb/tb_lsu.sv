`timescale 1ns/1ps

module tb_lsu;

    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] mem_rdata;
    logic [2:0]  funct3;
    logic        mem_read;
    logic        mem_write;

    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] rdata;

    int errors = 0;

    lsu dut (
        .addr(addr),
        .wdata(wdata),
        .mem_rdata(mem_rdata),
        .funct3(funct3),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .rdata(rdata)
    );

    task automatic check_load(input logic [31:0] addr_v,
                              input logic [31:0] mem_rdata_v,
                              input logic [2:0]  funct3_v,
                              input logic [31:0] exp_rdata,
                              input logic [31:0] exp_mem_addr);
        addr = addr_v;
        mem_rdata = mem_rdata_v;
        funct3 = funct3_v;
        mem_read = 1'b1;
        mem_write = 1'b0;

        #1;

        if (rdata !== exp_rdata || mem_addr !== exp_mem_addr) begin
            $error("LOAD FAIL: addr=%0h mem_rdata=%0h funct3=%0b got_rdata=%0h exp_rdata=%0h got_mem_addr=%0h exp_mem_addr=%0h",
                   addr_v, mem_rdata_v, funct3_v, rdata, exp_rdata, mem_addr, exp_mem_addr);
            errors++;
        end

        mem_read = 1'b0;
        #1;
    endtask

    task automatic check_store(input logic [31:0] addr_v,
                               input logic [31:0] wdata_v,
                               input logic [2:0]  funct3_v,
                               input logic [31:0] exp_mem_addr,
                               input logic [31:0] exp_mem_wdata,
                               input logic [3:0]  exp_mem_wstrb);
        addr = addr_v;
        wdata = wdata_v;
        funct3 = funct3_v;
        mem_read = 1'b0;
        mem_write = 1'b1;

        #1;

        if (mem_addr !== exp_mem_addr || mem_wdata !== exp_mem_wdata || mem_wstrb !== exp_mem_wstrb) begin
            $error("STORE FAIL: addr=%0h wdata=%0h funct3=%0b got_mem_addr=%0h exp_mem_addr=%0h got_wdata=%0h exp_wdata=%0h got_wstrb=%b exp_wstrb=%b",
                   addr_v, wdata_v, funct3_v,
                   mem_addr, exp_mem_addr,
                   mem_wdata, exp_mem_wdata,
                   mem_wstrb, exp_mem_wstrb);
            errors++;
        end

        mem_write = 1'b0;
        #1;
    endtask

    initial begin
        addr = 32'd0;
        wdata = 32'd0;
        mem_rdata = 32'd0;
        funct3 = 3'd0;
        mem_read = 1'b0;
        mem_write = 1'b0;

        // LB
        check_load(32'd0, 32'h00000080, 3'b000, 32'hFFFFFF80, 32'd0);

        // LBU
        check_load(32'd1, 32'h11223344, 3'b100, 32'h00000033, 32'd0);

        // LH
        check_load(32'd0, 32'h00008000, 3'b001, 32'hFFFF8000, 32'd0);

        // LHU
        check_load(32'd2, 32'h11223344, 3'b101, 32'h00001122, 32'd0);

        // LW
        check_load(32'd0, 32'h11223344, 3'b010, 32'h11223344, 32'd0);

        // SB
        check_store(32'd1, 32'h000000A5, 3'b000, 32'd0, 32'hA5A5A5A5, 4'b0010);

        // SH
        check_store(32'd2, 32'h0000BEEF, 3'b001, 32'd0, 32'hBEEF0000, 4'b1100);

        // SW
        check_store(32'd0, 32'hCAFEBABE, 3'b010, 32'd0, 32'hCAFEBABE, 4'b1111);

        if (errors == 0) begin
            $display("LSU TEST PASS");
            $finish;
        end else begin
            $error("LSU TEST FAIL: %0d errors", errors);
            $fatal(1, "LSU TEST FAILED");
        end
    end

endmodule