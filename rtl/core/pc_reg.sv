module pc_reg (
    input logic clk,
    input logic rst_n,
    input logic en,
    input logic [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'b0;
        end else if (en) begin
                pc <= next_pc;
        end
    end

endmodule