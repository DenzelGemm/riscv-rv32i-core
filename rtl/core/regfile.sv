module regfile(
    input logic clk,
    input logic rst_n,
    input logic we,
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] rd_addr,
    input logic [31:0] rd_data,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    logic [31:0] regs[31:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 32'd0;
            end
        end else if (we && rd_addr != 5'd0) begin
            regs[rd_addr] <= rd_data;
        end
    end

    assign rs1_data = (rs1_addr == 5'd0)               ? 32'd0   :
                  (we && (rs1_addr == rd_addr))    ? rd_data : 
                                                     regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0)               ? 32'd0   :
                  (we && (rs2_addr == rd_addr))    ? rd_data : 
                                                     regs[rs2_addr];

endmodule