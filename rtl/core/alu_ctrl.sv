module alu_ctrl (
    input  logic [1:0] alu_op,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    input  logic       is_rtype,
    output logic [3:0] alu_ctrl
);

    always_comb begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000;

            2'b01: alu_ctrl = 4'b1000;

            2'b10: begin
                case (funct3)
                    3'b000: begin
                        if (is_rtype && funct7_5)
                            alu_ctrl = 4'b1000;
                        else
                            alu_ctrl = 4'b0000;
                    end
                    3'b001: alu_ctrl = 4'b0001;
                    3'b010: alu_ctrl = 4'b0010;
                    3'b011: alu_ctrl = 4'b0011;
                    3'b100: alu_ctrl = 4'b0100;
                    3'b101: begin
                        if (funct7_5)
                            alu_ctrl = 4'b1101;
                        else
                            alu_ctrl = 4'b0101;
                    end
                    3'b110: alu_ctrl = 4'b0110;
                    3'b111: alu_ctrl = 4'b0111;
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule