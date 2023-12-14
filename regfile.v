module regfile(data_in, writenum, write, readnum, clk, data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;

    output [15:0] data_out;

    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [7:0] dec_out;
    wire [7:0] load;
    wire [7:0] dout_selector;
    
    reg [15:0] data_out;

    // 3 to 8 decoder needed to converted binary writenum to one hot code so that we can select the register to write to
    decoder_three_eight DECODER_THREE_EIGHT_ONE(.in(writenum), .out(dec_out));

    // Load is the bus of AND gate outputs
    assign load = (dec_out & {8{write}});

    vdff_w_load #(16) REG7(.clock(clk), .set(load[7]), .din(data_in), .dout(R7));	//Implementing register 7
    vdff_w_load #(16) REG6(.clock(clk), .set(load[6]), .din(data_in), .dout(R6));	//Implementing register 6
    vdff_w_load #(16) REG5(.clock(clk), .set(load[5]), .din(data_in), .dout(R5));	//Implementing register 5
    vdff_w_load #(16) REG4(.clock(clk), .set(load[4]), .din(data_in), .dout(R4));	//Implementing register 4
    vdff_w_load #(16) REG3(.clock(clk), .set(load[3]), .din(data_in), .dout(R3));	//Implementing register 3
    vdff_w_load #(16) REG2(.clock(clk), .set(load[2]), .din(data_in), .dout(R2));	//Implementing register 2
    vdff_w_load #(16) REG1(.clock(clk), .set(load[1]), .din(data_in), .dout(R1));	//Implementing register 1
    vdff_w_load #(16) REG0(.clock(clk), .set(load[0]), .din(data_in), .dout(R0));	//Implementing register 0

    // 3 to 8 decoder needed to converted binary readnum to one hot code so that we can select the register to read from
    decoder_three_eight DECODER_THREE_EIGHT_TWO(.in(readnum), .out(dout_selector));

    // Whenever the register read selector changes, the data output should be updated immediately with the data from the selected register
    always @* begin
        case (dout_selector)
            8'b10000000: data_out = R7;
            8'b01000000: data_out = R6;
            8'b00100000: data_out = R5;
            8'b00010000: data_out = R4;
            8'b00001000: data_out = R3;
            8'b00000100: data_out = R2;
            8'b00000010: data_out = R1;
            8'b00000001: data_out = R0;
            default: data_out = 8'bxxxxxxxx;
        endcase
    end
endmodule
