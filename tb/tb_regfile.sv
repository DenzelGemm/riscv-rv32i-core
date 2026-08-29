module tb_regfile;

    logic clk;
    logic rst_n;
    logic we;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [31:0] rd_data;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

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

    initial begin
        clk = 0;
        rst_n = 0;
        rs1_addr = 5'd0;
        rs2_addr = 5'd0;
        rd_addr = 5'd0;
        rd_data = 32'd0;
        we = 1'b0;

        #10 rst_n = 1;

    end

endmodule