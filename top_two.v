/*
 * clk input to datpath has rising edge when KEY0 is pressed
 *
 * HEX5 contains the status register output on the top (Z), middle (N) and
 * bottom (V) segment.
 *
 * HEX3, HEX2, HEX1, HEX0 are wired to out which should show the contents
 * of your register C.
 *
 * When SW[9] is set to 0, SW[7:0] changes the lower 8 bits of the 16-bit 
 * input "in". LEDR[8:0] will show the upper 8-bits of 16-bit input "in".
 *
 * When SW[9] is set to 1, SW[7:0] changes the upper 8 bits of the 16-bit
 * input "in". LEDR[8:0] will show the lower 8-bits of 16-bit input "in".
 *
 * The rising edge of clk occurs at the moment when you press KEY0.
 * The input reset is 1 as long as you press and hold KEY1.
 * The input s is 1 as long as you press and hold KEY2.
 * The input load is 1 as long as you press and hold KEY3.
 */

module top_two(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, CLOCK_50);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;

    output [9:0] LEDR; 
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire [15:0] out, ir;
    wire Z, N, V;

    input_interface INPUT_INTERFACE(CLOCK_50, SW, ir, LEDR[7:0]);

    // KEY0 is 1 when not pushed
    cpu CPU( .clk   (~KEY[0]),
             .reset (~KEY[1]), 
             .s     (~KEY[2]),
             .load  (~KEY[3]),
             .in    (ir),
             .out   (out),
             .Z     (Z),
             .N     (N),
             .V     (V),
             .w     (LEDR[9]) );

    assign HEX5[0] = ~Z;
    assign HEX5[6] = ~N;
    assign HEX5[3] = ~V;
    // Fill in sseg to display 4-bits in hexadecimal
    sseg H0(out[3:0],   HEX0);
    sseg H1(out[7:4],   HEX1);
    sseg H2(out[11:8],  HEX2);
    sseg H3(out[15:12], HEX3);
    assign HEX4 = 7'b1111111;
    // Disabled
    assign {HEX5[2:1], HEX5[5:4]} = 4'b1111;
    assign LEDR[8] = 1'b0;
endmodule

module input_interface(clk, SW, ir, LEDR);
    input clk;
    input [9:0] SW;
    output [15:0] ir;
    output [7:0] LEDR;
    wire sel_sw = SW[9];  
    wire [15:0] ir_next = sel_sw ? {SW[7:0], ir[7:0]} : {ir[15:8], SW[7:0]};
    vdff #(16) REG(clk, ir_next, ir);
    assign LEDR = sel_sw ? ir[7:0] : ir[15:8];  
endmodule         

/*
 * The sseg module below can be used to display the value of datpath_out on
 * the hex LEDs. The input is a 4-bit value representing numbers between 0 and
 * 15 while the output is a 7-bit value that will print a hexadecimal digit
 */

module sseg(in, segs);
    input [3:0] in;
    
    output [6:0] segs;

    reg [6:0] segs;

    always @* begin
        case(in)
            0: segs = 7'b1000000;
            1: segs = 7'b1001111;
            2: segs = 7'b0100100;
            3: segs = 7'b0110000;
            4: segs = 7'b0011001;
            5: segs = 7'b0010010;
            6: segs = 7'b0000010;
            7: segs = 7'b1111000;
            8: segs = 7'b0000000;
            9: segs = 7'b0010000;
            10: segs = 7'b0001000;
            11: segs = 7'b0000011;
            12: segs = 7'b1000110;
            13: segs = 7'b0100001;
            14: segs = 7'b0000110;
            15: segs = 7'b0001110;
            default: segs = 7'b0111111;
        endcase
    end
endmodule
