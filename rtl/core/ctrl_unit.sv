module ctrl_unit (
    input  logic [31:0] instr,

    output logic [3:0]  alu_op,
    output logic [2:0]  imm_src,
    output logic        alu_src_a_sel,
    output logic        alu_src_b_sel,
    output logic        mem_read,
    output logic        mem_write,
    output logic        reg_write,
    output logic [1:0]  reg_write_src_sel,
    output logic        branch,
    output logic        jump,
    output logic        jalr,
    output logic        fence,
    output logic        system,
    output logic [2:0]  funct3
);

    typedef enum logic [3:0] {
        ALU_ADD    = 4'b0000,
        ALU_SUB    = 4'b1000,
        ALU_SLL    = 4'b0001,
        ALU_SLT    = 4'b0010,
        ALU_SLTU   = 4'b0011,
        ALU_XOR    = 4'b0100,
        ALU_SRL    = 4'b0101,
        ALU_SRA    = 4'b1100,
        ALU_OR     = 4'b0110,
        ALU_AND    = 4'b0111,
        ALU_PASS_B = 4'b1111
    } alu_op_e;

    typedef enum logic [2:0] {
        IMM_I = 3'b000,
        IMM_S = 3'b001,
        IMM_B = 3'b010,
        IMM_U = 3'b011,
        IMM_J = 3'b100
    } imm_src_e;

    typedef enum logic [1:0] {
        WB_ALU = 2'b00,
        WB_MEM = 2'b01,
        WB_PC4 = 2'b10
    } wb_src_e;

    typedef enum logic [6:0] {
        OP_R_TYPE = 7'b0110011,
        OP_I_ALU  = 7'b0010011,
        OP_LOAD   = 7'b0000011,
        OP_STORE  = 7'b0100011,
        OP_BRANCH = 7'b1100011,
        OP_JAL    = 7'b1101111,
        OP_JALR   = 7'b1100111,
        OP_LUI    = 7'b0110111,
        OP_AUIPC  = 7'b0010111
    } opcode_e;

    logic [6:0] opcode;
    logic       funct7_5;

    assign opcode   = instr[6:0];
    assign funct3   = instr[14:12];
    assign funct7_5 = instr[30];

    always_comb begin
        alu_op            = ALU_ADD;
        imm_src           = IMM_I;
        alu_src_a_sel     = 1'b0;
        alu_src_b_sel     = 1'b0;
        mem_read          = 1'b0;
        mem_write         = 1'b0;
        reg_write         = 1'b0;
        reg_write_src_sel = WB_ALU;
        branch            = 1'b0;
        jump              = 1'b0;
        jalr              = 1'b0;
        fence             = 1'b0;
        system            = 1'b0;

        unique case (opcode)
            OP_R_TYPE: begin
                reg_write = 1'b1;
                unique case (funct3)
                    3'b000:  alu_op = funct7_5 ? ALU_SUB : ALU_ADD;
                    3'b001:  alu_op = ALU_SLL;
                    3'b010:  alu_op = ALU_SLT;
                    3'b011:  alu_op = ALU_SLTU;
                    3'b100:  alu_op = ALU_XOR;
                    3'b101:  alu_op = funct7_5 ? ALU_SRA : ALU_SRL;
                    3'b110:  alu_op = ALU_OR;
                    3'b111:  alu_op = ALU_AND;
                    default: alu_op = ALU_ADD;
                endcase
            end

            OP_I_ALU: begin
                imm_src       = IMM_I;
                reg_write     = 1'b1;
                alu_src_b_sel = 1'b1;
                unique case (funct3)
                    3'b000:  alu_op = ALU_ADD;
                    3'b001:  alu_op = ALU_SLL;
                    3'b010:  alu_op = ALU_SLT;
                    3'b011:  alu_op = ALU_SLTU;
                    3'b100:  alu_op = ALU_XOR;
                    3'b101:  alu_op = funct7_5 ? ALU_SRA : ALU_SRL;
                    3'b110:  alu_op = ALU_OR;
                    3'b111:  alu_op = ALU_AND;
                    default: alu_op = ALU_ADD;
                endcase
            end

            OP_LOAD: begin
                imm_src           = IMM_I;
                alu_src_b_sel     = 1'b1;
                alu_op            = ALU_ADD;
                mem_read          = 1'b1;
                reg_write         = 1'b1;
                reg_write_src_sel = WB_MEM;
            end

            OP_STORE: begin
                imm_src       = IMM_S;
                alu_src_b_sel = 1'b1;
                alu_op        = ALU_ADD;
                mem_write     = 1'b1;
            end

            OP_BRANCH: begin
                imm_src = IMM_B;
                branch  = 1'b1;
                alu_op  = ALU_SUB;
            end

            OP_JAL: begin
                imm_src           = IMM_J;
                alu_src_a_sel     = 1'b1;
                alu_src_b_sel     = 1'b1;
                alu_op            = ALU_ADD;
                jump              = 1'b1;
                reg_write         = 1'b1;
                reg_write_src_sel = WB_PC4;
            end

            OP_JALR: begin
                imm_src           = IMM_I;
                jump              = 1'b1;
                jalr              = 1'b1;
                reg_write         = 1'b1;
                reg_write_src_sel = WB_PC4;
                alu_src_b_sel     = 1'b1;
                alu_op            = ALU_ADD;
            end

            OP_LUI: begin
                imm_src       = IMM_U;
                reg_write     = 1'b1;
                alu_src_b_sel = 1'b1;
                alu_op        = ALU_PASS_B;
            end

            OP_AUIPC: begin
                imm_src       = IMM_U;
                reg_write     = 1'b1;
                alu_src_a_sel = 1'b1;
                alu_src_b_sel = 1'b1;
                alu_op        = ALU_ADD;
            end

            7'b0001111: begin
                if (funct3 == 3'b000)
                    fence = 1'b1;
            end

            7'b1110011: begin
                system = 1'b1;
            end

            default: ;
        endcase
    end

endmodule