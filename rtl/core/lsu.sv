module lsu (
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [31:0] mem_rdata,
    input  logic [2:0]  funct3,
    input  logic        mem_read,
    input  logic        mem_write,

    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    output logic [3:0]  mem_wstrb,
    output logic [31:0] rdata
);

    logic [31:0] shifted_rdata;
    logic [7:0]  load_byte;
    logic [15:0] load_half;

    always_comb begin
        mem_addr  = {addr[31:2], 2'b00};
        mem_wdata = 32'b0;
        mem_wstrb = 4'b0000;
        rdata     = 32'b0;

        shifted_rdata = mem_rdata >> (addr[1:0] * 8);
        load_byte     = shifted_rdata[7:0];
        load_half     = shifted_rdata[15:0];

        if (mem_read) begin
            case (funct3)
                3'b000: rdata = {{24{load_byte[7]}}, load_byte}; 
                3'b001: rdata = {{16{load_half[15]}}, load_half}; 
                3'b010: rdata = mem_rdata;
                3'b100: rdata = {24'b0, load_byte};
                3'b101: rdata = {16'b0, load_half};
                default: rdata = 32'b0;
            endcase
        end

        if (mem_write) begin
            case (funct3)
                3'b000: begin
                    mem_wdata = {4{wdata[7:0]}};
                    mem_wstrb = 4'b0001 << addr[1:0];
                end

                3'b001: begin
                    mem_wdata = {2{wdata[15:0]}};
                    mem_wstrb = 4'b0011 << {addr[1], 1'b0};
                end

                3'b010: begin
                    mem_wdata = wdata;
                    mem_wstrb = 4'b1111;
                end

                default: begin
                    mem_wdata = 32'b0;
                    mem_wstrb = 4'b0000;
                end
            endcase
        end
    end

endmodule