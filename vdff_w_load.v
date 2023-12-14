module vdff_w_load(clock, set, din, dout);
    parameter k = 16;

    input [k-1:0] din;
    input clock, set;

    output [k-1:0] dout;

    reg [k-1:0] mux_out;
    reg [k-1:0] dout;

    // If load is set to 0, the output of the mux is not updated from its present value
    always @* begin
        if (set == 1'b0)
            mux_out = dout;
        else
            mux_out = din;
    end

    // At the rising edge of the clock, Q gets the value of D
    always @(posedge clock) begin
        dout = mux_out;
    end
endmodule
