module instruc_reg(clk, in, load, out);
    input [15:0] in;
    input load, clk;
    
    output [15:0] out;

    reg [15:0] out;
    reg [15:0] mux_out;

    // Checking whether we should update current data with input
    always @* begin
        if (load == 1'b0)
            mux_out = out;
        else
            mux_out = in;
    end

    // Outputting the data on the rising edge of the clock
    always @(posedge clk) begin
        out = mux_out;
    end
endmodule
