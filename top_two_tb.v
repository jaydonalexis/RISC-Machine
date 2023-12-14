module top_two_tb();
    reg [15:0] in;
    reg clk, reset, s, load;
    reg err;

    wire [15:0] out;
    wire N, V, Z, w;

    cpu DUT(clk, reset, s, load, in, out, N, V, Z, w);

    initial begin
        clk = 0; #5;

        forever begin
            clk = 1; #5;
            clk = 0; #5;
        end
    end

    initial begin
        err = 0;
        reset = 1; s = 0; load = 0; in = 16'b0;
        #10;

        reset = 0; 
        #10;

        in = 16'b1101000000000111;
        load = 1;
        #10;

        load = 0;
        s = 1;
        #10
        
        s = 0;
        // Wait for w to go high again
        @(posedge w);
        #10;

        if (top_two_tb.DUT.DP.REGFILE.R0 !== 16'h7) begin
            err = 1;
            $display("FAILED: MOV R0, #7");
            $stop;
        end

        in = 16'b1101000100000010;
        load = 1;
        #10;

        load = 0;
        s = 1;
        #10

        s = 0;
        // Wait for w to go high again
        @(posedge w);
        #10;

        if (top_two_tb.DUT.DP.REGFILE.R1 !== 16'h2) begin
            err = 1;
            $display("FAILED: MOV R1, #2");
            $stop;
        end

        in = 16'b1010000101001000;
        load = 1;
        #10;

        load = 0;
        s = 1;
        #10

        s = 0;
        // Wait for w to go high again
        @(posedge w);
        #10;

        if (top_two_tb.DUT.DP.REGFILE.R2 !== 16'h10) begin
            err = 1;
            $display("FAILED: ADD R2, R1, R0, LSL#1");
            $stop;
        end

        if (~err) $display("INTERFACE OK");
        
        $stop;
    end
endmodule
