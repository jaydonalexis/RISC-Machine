module alu(Ain, Bin, ALUop, out, Z);
    input [15:0] Ain, Bin;
    output [15:0] out;
    output [2:0] Z;
    input [1:0] ALUop;

    reg [15:0] out;
    reg [2:0] Z;
    
    // Whenever the ALU operation input changes, the output of the ALU should be updated immediately according to the selected operation
    always @* begin
        case(ALUop)
            2'b00: out = Ain + Bin;
            2'b01: out = Ain - Bin;
            2'b10: out = Ain & Bin;
            2'b11: out = ~(Bin);
            default: out = ({16{1'bx}});
        endcase

        // If the 16 bit output of the ALU is 0, then the Z output of the ALU should be 1, otherwise 0
        if (out == {16{1'b0}})
            Z[0] = 1'b1;
        else
            Z[0] = 1'b0;

        // We are using signed numbers so if the MSB is a one, then the number is a negative number
        if(out[15] == 1'b1)
            Z[2] = 1'b1;
        else 
            Z[2] = 1'b0;

        // If the carry in is not equal to the carry out for the MSB, then there is an overflow
        if ((Ain[6] & Bin[6]) !== (Ain[7] & Bin[7]))
            Z[1] = 1'b1;
        else
            Z[1] = 1'b0;
    end
endmodule
