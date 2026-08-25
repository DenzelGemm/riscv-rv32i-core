module imm_gen (
    input  logic [31:0] instr,
    input  logic [2:0]  imm_sel,
    output logic [31:0] imm
);

    typedef enum logic [2:0] {
        I_TYPE = 3'b000,
        S_TYPE = 3'b001,
        B_TYPE = 3'b010,
        U_TYPE = 3'b011,
        J_TYPE = 3'b100
    } imm_type_e;

    always_comb begin
        case (imm_sel)
            I_TYPE: imm = {{20{instr[31]}}, instr[31:20]};
            S_TYPE: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            B_TYPE: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            U_TYPE: imm = {instr[31:12], 12'b0};
            J_TYPE: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = 32'd0;
        endcase
    end

endmodule