module branch_comp (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [2:0]  funct3,
    output logic        br_taken
);

    typedef enum logic [2:0] {
        BEQ  = 3'b000,
        BNE  = 3'b001,
        BLT  = 3'b100,
        BGE  = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } branch_type_e;

    always_comb begin
        case (funct3)
            BEQ  : br_taken = (rs1_data == rs2_data);
            BNE  : br_taken = (rs1_data != rs2_data);
            BLT  : br_taken = ($signed(rs1_data) <  $signed(rs2_data));
            BGE  : br_taken = ($signed(rs1_data) >= $signed(rs2_data));
            BLTU : br_taken = (rs1_data <  rs2_data);
            BGEU : br_taken = (rs1_data >= rs2_data);
            default : br_taken = 1'b0;
        endcase
    end

endmodule