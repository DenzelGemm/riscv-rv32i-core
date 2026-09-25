module instr_mem #(
    parameter string INIT_FILE = ""
) (
    input  logic [31:0] addr,
    output logic [31:0] rdata
);

    logic [31:0] mem [0:1023];

    initial begin
        for (int i = 0; i < 1024; i++)
            mem[i] = 32'd0;

        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    always_comb begin
        rdata = mem[addr[11:2]];
    end

endmodule