module shifter(in, shift, sout);
    input [15:0] in;
    input [1:0] shift;
    
    output [15:0] sout;

    reg [15:0] sout;
    
    // Whenever the shift operation input changes, the output of the shifter should immediately be updated accordingly
    always @* begin
        case(shift)
            2'b00: sout = in;
            // Left shift, LSB is 0
            2'b01: sout = ({in[14:0], 1'b0});
            // Left shift, MSB is 0
            2'b10: sout = ({1'b0, in[15:1]});
            // Right shift, MSB copy of B[15]
            2'b11: sout = ({in[15], in[15:1]});
            default: sout = {16{1'bx}};
        endcase
    end
endmodule
