/*
 * Register read stage:
 * readnum SW[3:1]
 * loada SW[5]
 * loadb SW[6]
 * Execute stage:
 * shift SW[2:1]
 * asel SW[3]
 * bsel SW[4]
 * ALUop SW[6:5]
 * loadc SW[7]
 * loads SW[8]
 * Writeback stage:
 * write SW[0]      
 * writenum SW[3:1]
 * vsel SW[4]
 */

module top_one(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, CLOCK_50);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;

    output [9:0] LEDR; 
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire [15:0] datapath_out, datapath_in;
    wire [2:0] readnum, writenum;
    wire [1:0] shift, ALUop;
    wire write, vsel, loada, loadb, asel, bsel, loadc, loads;

    input_interface INPUT_INTERFACE(CLOCK_50, SW, datapath_in, write, vsel, loada, loadb, asel, 
                                    bsel, loadc, loads, readnum, writenum, shift, ALUop, LEDR[8:0]);

                      // KEY0 is 1 when not pushed
    datapath DATAPATH(.clk           (~KEY[0]),
                      // Register operand fetch stage
                      .readnum       (readnum),
                      .vsel          (vsel),
                      .loada         (loada),
                      .loadb         (loadb),
                      // Computation stage
                      .shift         (shift),
                      .asel          (asel),
                      .bsel          (bsel),
                      .ALUop         (ALUop),
                      .loadc         (loadc),
                      .loads         (loads),
                      // Set when writing back to register file
                      .writenum      (writenum),
                      .write         (write),
                      .datapath_in   (datapath_in),
                      // Outputs
                      .Z_out         (LEDR[9]),
                      .datapath_out  (datapath_out)
                      );

    // Fill in sseg to display 4-bits in hexadecimal
    sseg H0(datapath_out[3:0],   HEX0);   
    sseg H1(datapath_out[7:4],   HEX1);
    sseg H2(datapath_out[11:8],  HEX2);
    sseg H3(datapath_out[15:12], HEX3);
    // Disabled
    assign HEX4 = 7'b1111111;
    // Disabled
    assign HEX5 = 7'b1111111;
endmodule


module input_interface(clk, SW, datapath_in, write, vsel, loada, loadb, asel, bsel, 
                       loadc, loads, readnum, writenum, shift, ALUop, LEDR);
    input [9:0] SW;
    input clk;

    output [15:0] datapath_in;
    output [8:0] LEDR;
    output [2:0] readnum, writenum;
    output [1:0] shift, ALUop;
    output write, vsel, loada, loadb, asel, bsel, loadc, loads;
 
    // When SW[9] is set to 1, SW[7:0] changes the lower 8 bits of datpath_in
    wire [15:0] datapath_in_next = sel_sw ? {8'b0, SW[7:0]} : datapath_in
    // When SW[9] is set to 0, SW[8:0] changes the control inputs 
    wire [8:0] ctrl_sw;
    wire [8:0] ctrl_sw_next = sel_sw ? ctrl_sw : SW[8:0];
    wire sel_sw = SW[9]; 

    vdff #(16) DATA(clk, datapath_in_next, datapath_in);
    vdff #(9) CTRL(clk, ctrl_sw_next, ctrl_sw);

    assign {readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write} = {
        // Register operand fetch stage
        ctrl_sw[3:1], ctrl_sw[4], ctrl_sw[5], ctrl_sw[6], 
        // Computation stage
        ctrl_sw[2:1], ctrl_sw[3], ctrl_sw[4], ctrl_sw[6:5], ctrl_sw[7], ctrl_sw[8],
        // Set when writing back to register file
        ctrl_sw[3:1], ctrl_sw[0]    
    };

    // LEDR[7:0] shows other bits
    assign LEDR = sel_sw ? ctrl_sw : {1'b0, datapath_in[7:0]};  
endmodule         


module vdff(clk, D, Q);
    parameter n=1;

    input [n-1:0] D;
    input clk;

    output [n-1:0] Q;

    reg [n-1:0] Q;

    always @(posedge clk)
        Q <= D;
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
