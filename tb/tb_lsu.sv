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

    initial begin
        addr = 32'd0;
        wdata = 32'd0;
        mem_rdata = 32'd0;
        funct3 = 3'd0;
        mem_read = 1'b0;
        mem_write = 1'b0;

        #10;

    end

endmodule