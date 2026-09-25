module rv32i_core (
    input  logic        clk,
    input  logic        rst_n,

    output logic [31:0] imem_addr,
    input  logic [31:0] imem_rdata,

    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    output logic [3:0]  dmem_wstrb,
    output logic        dmem_read,
    output logic        dmem_write,
    input  logic [31:0] dmem_rdata
);

    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] instr;
    logic [31:0] pc_plus4;

    logic [3:0] alu_op;
    logic [2:0] imm_src;
    logic alu_src_a_sel;
    logic alu_src_b_sel;
    logic mem_read;
    logic mem_write;
    logic reg_write;
    logic [1:0] reg_write_src_sel;
    logic branch;
    logic jump;
    logic jalr;
    logic fence;
    logic system;
    logic [2:0] funct3;

    logic [31:0] imm;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] rd_data;

    logic [31:0] alu_a;
    logic [31:0] alu_b;

    logic [31:0] alu_result;
    logic alu_zero; //zero flag is unused in this design, so better to remove it to avoid lint warnings, in alu.sv to

    logic br_taken;
    logic take_branch;

    logic [31:0] load_data;

    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;

    pc_reg u_pc (
        .clk     (clk),
        .rst_n   (rst_n),
        .en      (1'b1),
        .next_pc (next_pc),
        .pc      (pc)
    );

    ctrl_unit u_ctrl (
        .instr              (instr),
        .alu_op             (alu_op),
        .imm_src            (imm_src),
        .alu_src_a_sel      (alu_src_a_sel),
        .alu_src_b_sel      (alu_src_b_sel),
        .mem_read           (mem_read),
        .mem_write          (mem_write),
        .reg_write          (reg_write),
        .reg_write_src_sel  (reg_write_src_sel),
        .branch             (branch),
        .jump               (jump),
        .jalr               (jalr),
        .fence              (fence),
        .system             (system),
        .funct3             (funct3)
    );

    imm_gen u_imm_gen (
        .instr   (instr),
        .imm_src (imm_src),
        .imm     (imm)
    );

    regfile u_regfile (
        .clk      (clk),
        .rst_n    (rst_n),
        .we       (reg_write),
        .rs1_addr (instr[19:15]),
        .rs2_addr (instr[24:20]),
        .rd_addr  (instr[11:7]),
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    alu u_alu (//zero flag better to remove from alu.sv
        .a      (alu_a),
        .b      (alu_b),
        .alu_op (alu_op),
        .result (alu_result),
        .zero   (alu_zero)
    );

    branch_comp u_branch_comp (
        .rs1_data (rs1_data),
        .rs2_data (rs2_data),
        .funct3   (funct3),
        .br_taken (br_taken)
    );

    lsu u_lsu (
        .addr      (alu_result),
        .wdata     (rs2_data),
        .mem_rdata (dmem_rdata),
        .funct3    (funct3),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .mem_addr  (dmem_addr),
        .mem_wdata (dmem_wdata),
        .mem_wstrb (dmem_wstrb),
        .rdata     (load_data)
    );

    assign imem_addr = pc;
    assign instr = imem_rdata;
    assign pc_plus4 = pc + 32'd4;
    assign dmem_read = mem_read;
    assign dmem_write = mem_write;

    assign alu_a = alu_src_a_sel ? pc : rs1_data;
    assign alu_b = alu_src_b_sel ? imm : rs2_data;

    assign take_branch = branch && br_taken;

    always_comb begin
        case (reg_write_src_sel)
            2'b00: rd_data = alu_result;
            2'b01: rd_data = load_data;
            2'b10: rd_data = pc_plus4;
            default: rd_data = 32'd0;
        endcase
    end

    assign branch_target = pc + imm;
    assign jal_target    = pc + imm;
    assign jalr_target   = (rs1_data + imm) & 32'hFFFF_FFFE;

    always_comb begin
        next_pc = pc_plus4;

        if (take_branch)
            next_pc = branch_target;

        if (jump && !jalr)
            next_pc = jal_target;

        if (jump && jalr)
            next_pc = jalr_target;
    end

endmodule