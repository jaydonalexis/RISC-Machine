module vdff(clk, in, out);
    parameter n = 1;

    input [n-1:0] in;
    input clk;

    output [n-1:0] out;

    reg [n-1:0] out;

    always @(posedge clk) begin
        out = in;
    end
endmodule
