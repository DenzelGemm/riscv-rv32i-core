module data_mem (
    input  logic        clk,

    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,
    input  logic        read,
    input  logic        write,

    output logic [31:0] rdata
);

    logic [31:0] mem [0:1023] = '{default: 32'd0};

    always_comb begin
        if (read)
            rdata = mem[addr[11:2]];
        else
            rdata = 32'd0;
    end

    always_ff @(posedge clk) begin
        if (write) begin
            if (wstrb[0])
                mem[addr[11:2]][7:0] <= wdata[7:0];

            if (wstrb[1])
                mem[addr[11:2]][15:8] <= wdata[15:8];

            if (wstrb[2])
                mem[addr[11:2]][23:16] <= wdata[23:16];

            if (wstrb[3])
                mem[addr[11:2]][31:24] <= wdata[31:24];
        end
    end

endmodule