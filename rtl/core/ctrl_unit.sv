module ctrl_unit (
    input  logic [31:0] instr,

    output logic [3:0]  alu_op,
    output logic        alu_src_a_sel,
    output logic        alu_src_b_sel,
    output logic        mem_read,
    output logic        mem_write,
    output logic        reg_write,
    output logic [1:0]  reg_write_src_sel,
    output logic        branch,
    output logic        jump,
    output logic [2:0]  funct3
);

    typedef enum logic [3:0] {
        ALU_ADD    = 4'b0000,
        ALU_SUB    = 4'b0001,
        ALU_SLL    = 4'b0010,
        ALU_SLT    = 4'b0011,
        ALU_SLTU   = 4'b0100,
        ALU_XOR    = 4'b0101,
        ALU_SRL    = 4'b0110,
        ALU_SRA    = 4'b0111,
        ALU_OR     = 4'b1000,
        ALU_AND    = 4'b1001,
        ALU_PASS_B = 4'b1010
    } alu_op_e;

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
        alu_src_a_sel     = 1'b0;
        alu_src_b_sel     = 1'b0;
        mem_read          = 1'b0;
        mem_write         = 1'b0;
        reg_write         = 1'b0;
        reg_write_src_sel = WB_ALU;
        branch            = 1'b0;
        jump              = 1'b0;

        unique case (opcode)
            OP_R_TYPE: begin
                reg_write     = 1'b1;
                alu_src_a_sel = 1'b0;
                alu_src_b_sel = 1'b0;
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
                alu_src_b_sel     = 1'b1;
                alu_op            = ALU_ADD;
                mem_read          = 1'b1;
                reg_write         = 1'b1;
                reg_write_src_sel = WB_MEM;
            end

            OP_STORE: begin
                alu_src_b_sel = 1'b1;
                alu_op        = ALU_ADD;
                mem_write     = 1'b1;
            end

            OP_BRANCH: begin
                branch = 1'b1;
                alu_op = ALU_SUB;
            end

            OP_JAL: begin
                jump              = 1'b1;
                reg_write         = 1'b1;
                reg_write_src_sel = WB_PC4;
            end

            OP_JALR: begin
                jump              = 1'b1;
                reg_write         = 1'b1;
                reg_write_src_sel = WB_PC4;
                alu_src_b_sel     = 1'b1;
                alu_op            = ALU_ADD;
            end

            OP_LUI: begin
                reg_write     = 1'b1;
                alu_src_b_sel = 1'b1;
                alu_op        = ALU_PASS_B;
            end

            OP_AUIPC: begin
                reg_write     = 1'b1;
                alu_src_a_sel = 1'b1;
                alu_src_b_sel = 1'b1;
                alu_op        = ALU_ADD;
            end

            default: ;
        endcase
    end

endmodule