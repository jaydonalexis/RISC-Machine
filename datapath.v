module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc,
                loads, writenum, write, sximm8, sximm5, Z_out, datapath_out, mdata, PC);
    input [15:0] sximm8, mdata, sximm5;
    input [8:0] PC;
    input [3:0] vsel;
    input [2:0] readnum, writenum;
    input [1:0] ALUop, shift;
    input clk, write, loada, loadb, asel, bsel, loadc, loads;

    output [15:0] datapath_out;
    output [2:0] Z_out;

    wire [15:0] data_out, A_out, B_out, sout, out;
    wire [2:0] Z_out, Z;

    reg [15:0] data_in, Ain, Bin;

    // Implementation of the mux to select the input for the register file to either be data out or external data in
    always @* begin
        case (vsel)
            4'b1000: data_in = mdata;
            4'b0100: data_in = sximm8;
            4'b0010: data_in = {7'b0000000, PC};
            4'b0001: data_in = datapath_out;
            default: data_in = {16{1'bx}};
        endcase
    end

    // Instantiation of the register file
    regfile REGFILE(.data_in(data_in), .writenum(writenum), .write(write),
                    .readnum(readnum), .clk(clk), .data_out(data_out));

    // Instantiation of register A
    vdff_w_load #(16) A(.clock(clk), .set(loada), .din(data_out), .dout(A_out));

    // Instantiation of register B
    vdff_w_load #(16) B(.clock(clk), .set(loadb), .din(data_out), .dout(B_out));

    // Instantiation of shifter
    shifter SHIFTER(.in(B_out), .shift(shift), .sout(sout));

    // Implementation of the mux to select between 16'b0 or output of register A to input of the ALU
    always @* begin
        case(asel)
            1'b1: Ain = {16{1'b0}};
            1'b0: Ain = A_out;
            default: Ain = {16{1'bx}};
        endcase
    end

    // Implementation of the mux to select between {11'b0, datapath_in[4:0]} or output of the shifter to the input of the ALU
    always @* begin
        case(bsel)
            1'b1: Bin = sximm5;
            1'b0: Bin = sout;
            default: Bin = {16{1'bx}};
        endcase
    end

    // Instantiation of the ALU needed for arithmetic operations
    alu ALU(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(out), .Z(Z));

    // Instantiation of the C register
    vdff_w_load #(16) C(.clock(clk), .set(loadc), .din(out), .dout(datapath_out));

    // Instantiation of the status register
    vdff_w_load #(3) STATUS(.clock(clk), .set(loads), .din(Z), .dout(Z_out));
endmodule
    