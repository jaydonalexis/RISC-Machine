module instruc_dec(in, opcode, op, nsel, writenum, readnum, shift, sximm8, sximm5, ALUop);
    input [15:0] in;
    input [2:0] nsel;

    output [15:0] sximm8, sximm5;
    output [2:0] opcode;
    output [2:0] writenum, readnum;
    output [1:0] op, shift, ALUop;

    reg [15:0] sximm5, sximm8;
    reg [7:0] imm8;
    reg [4:0] imm5;
    reg [2:0] writenum, readnum, opcode, Rn, Rd, Rm;
    reg [1:0] ALUop, shift, op;

    // We are dissecting the in bit field into the various external module inputs
    always @* begin
        opcode = in[15:13];
        op = in[12:11];
        Rm = in[2:0];
        Rd = in[7:5];
        Rn = in[10:8];
        shift = in[4:3];
        imm8 = in[7:0];
        imm5 = in[4:0];
        ALUop = in[12:11];
    end

    // We are selecting the register to either read or write based on the inputs Rn, Rd, Rm
    always @* begin
        case(nsel)
            3'b100: begin writenum = Rn; readnum = Rn; end 
            3'b010: begin writenum = Rd; readnum = Rd; end
            3'b001: begin writenum = Rm; readnum = Rm; end
            default: begin writenum = 3'bxxx; readnum = 3'bxxx; end
        endcase
    end

    // Sign extending imm8 to 16 bits
    always @* begin
        if(imm8[7] == 1'b1) begin
            sximm8 = {8'b11111111, imm8};
        end
        else begin
            sximm8 = {8'b00000000, imm8};
        end
    end

    // Sign extending imm5 to 16 bits
    always @* begin
        if(imm5[4] == 1'b1) begin
            sximm5 = {11'b11111111111, imm5};
        end
        else begin
            sximm5 = {11'b00000000000, imm5};
        end
    end
endmodule
    