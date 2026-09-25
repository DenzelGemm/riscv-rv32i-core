module rv32i_top #(
    parameter string IMEM_INIT_FILE = "tb/program.hex"
) (
    input logic clk,
    input logic rst_n
);

    logic [31:0] imem_addr;
    logic [31:0] imem_rdata;

    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [3:0]  dmem_wstrb;
    logic        dmem_read;
    logic        dmem_write;
    logic [31:0] dmem_rdata;

    rv32i_core u_core (
        .clk        (clk),
        .rst_n      (rst_n),

        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),

        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_wstrb (dmem_wstrb),
        .dmem_read  (dmem_read),
        .dmem_write (dmem_write),
        .dmem_rdata (dmem_rdata)
    );

    instr_mem #(
        .INIT_FILE (IMEM_INIT_FILE)
    ) u_instr_mem (
        .addr  (imem_addr),
        .rdata (imem_rdata)
    );

    data_mem u_data_mem (
        .clk   (clk),
        .addr  (dmem_addr),
        .wdata (dmem_wdata),
        .wstrb (dmem_wstrb),
        .read  (dmem_read),
        .write (dmem_write),
        .rdata (dmem_rdata)
    );

endmodule