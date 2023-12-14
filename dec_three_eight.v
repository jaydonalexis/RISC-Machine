module decoder_three_eight(in, out);
    input [2:0] in;
    
    output [7:0] out;

    // Shifting the one "in" positions to the left to implement one hot code
    wire [7:0] out = 1 << in;
endmodule
