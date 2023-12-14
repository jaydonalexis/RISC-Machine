module cpu_tb();
    wire [15:0] sim_out;
    wire sim_N, sim_V, sim_Z, sim_w;

    reg [15:0] sim_in;
    reg sim_clk, sim_reset, sim_s, sim_load;
    reg err;

    cpu DUT(.clk(sim_clk), .reset(sim_reset), .s(sim_s), .load(sim_load),
            .in(sim_in), .out(sim_out), .N(sim_N), .V(sim_V), .Z(sim_Z),
            .w(sim_w));

    initial begin
        sim_clk = 1'b0;
        // We are running the clock cycles in the background of the test suite
        forever begin
        // The clock cycles last 2 ps so it takes 4 ps for a rising edge to appear
            #2;
            sim_clk = 1'b1;
            #2;
            sim_clk = 1'b0;
        end
    end

    initial begin
        err = 1'b0;
        // MOV R0, #4
        sim_in = 16'b1101000000000100;
        sim_s = 1'b1;
        sim_reset = 1'b0;
        sim_load = 1'b1;
        // Delay by 4ps * number of clock rising edges needed
        #12;

        /* Test #1: Move contents between registers */

        // MOV R1, R0
        sim_in = 16'b1100000000100000;
        #8;

        // If statements used throughout to check if the changes were made/not made correctly
        if(sim_out != 16'b0000000000000100) begin
            err = 1'b1;
            $display("Error: r0 is %b, expected 4", sim_out);
        end

        /* Test #2: Load */

        // MOV R2, R0, LSL #1
        sim_in = 16'b1100000001001000;
        // Load is set to 0 to make sure that no changes occur when its 0
        sim_load = 1'b0;
        #8;

        // If it has updated, there is an error
        if(sim_out == 16'b0000000000001000) begin
            err = 1'b1;
            $display("Error: r0 should not have updated to 8");
        end

        // MOV R2, #115
        sim_in = 16'b1101001001110011;
        // Load is back to 1 to proceed with future tests
        sim_load = 1'b1;
        #12;
            
        /* Test #3: Adding with left shift */

        // ADD R3, R2, R1, LSL #1
        sim_in = 16'b1010001001101001;
        #24;

        // Output should be 123
        if(sim_out != 16'b0000000001111011) begin
            err = 1'b1;
            $display("Error: out is %b, expected 123", sim_out);
        end

        /* Test #4: AND with right shift */

        // AND R4, R3, R0, LSR #1
        sim_in = 16'b1011001110010000;
        #24;

        // Output should be 2
        if(sim_out != 16'b0000000000000010) begin
            err = 1'b1;
            $display("Error: out is %b, expected 2", sim_out);
        end

        /* Test #5: MVN without shift */

        // MVN R5, R2
        sim_in = 16'b1011100010100010;
        #24;

        // Output should be -116
        if(sim_out != 16'b1111111110001100) begin
            err = 1'b1;
            $display("Error: out is %b, expected -116", sim_out);
        end

        // The following tests are using cmp to test the Z N V outputs

        /* Test #6: CMP R0(4), R1(4), LSR #1; */

        sim_in = 16'b1010100000010001;
        #24;
        
        // 4 - 2 = 2 then N should be 0
        if(sim_N != 1'b0)
            err = 1'b1;

        /* Test #7: CMP R0(4), R1(4), LSL #1; */

        sim_in = 16'b1010100000001001;
        #24;

        // 4 - 8 = -4 then N should be 1
        if(sim_N != 1'b1)
            err = 1'b1;

        /* Test #8: CMP R0, R1 */

        sim_in = 16'b1010100000000001;
        #24;

        // 4 - 4 = 0 then Z should be 1;
        if(sim_Z != 1'b1 || sim_N == 1'b1)
            err = 1'b1;

        /* Test #9: Testing the S/W */

        // Setting s to 0
        sim_s = 1'b0;
        // Run through some cycles
        #12;

        // w should be set to 1
        if(sim_w != 1'b1) begin
            err = 1'b1;
            $display("Error: w should be 1");
        end

        /* Test #10: V */

        // MOV R6, #255
        sim_in = 16'b1101011001111111;
        sim_s = 1'b1;
        #12;

        // MOV R7, #255
        sim_in = 16'b1101011101111111;
        #12;

        // ADD R7, R7, R6
        sim_in = 16'b1010011111100110;
        #24;

        // At this point V should go high as there is an overflow
        if(sim_V != 1'b1) begin
            err = 1'b1;
            $display("Error: V should be 1");
        end

        #4;

        if(err == 1'b0)
            $display("No Errors :)");

        $stop;
    end
endmodule






