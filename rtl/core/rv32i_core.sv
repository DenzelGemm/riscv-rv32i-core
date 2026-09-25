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

    assign imem_addr = pc;
    assign pc_plus4 = pc + 32'd4;

endmodule