module top_three_tb();
    reg [9:0] SW;
    reg [3:0] KEY;
    reg err;

    wire [9:0] LEDR; 
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    top_three DUT(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

    initial forever begin
        KEY[0] = 1; #5;
        KEY[0] = 0; #5;
    end

    initial begin
        err = 0;
        // Reset asserted
        KEY[1] = 1'b0;
        if (DUT.MEM.mem[0] !== 16'b1101000000000101) begin err = 1; $display("FAILED: mem[0] wrong; please set data.txt using Figure 6"); $stop; end
        if (DUT.MEM.mem[1] !== 16'b0110000000100000) begin err = 1; $display("FAILED: mem[1] wrong; please set data.txt using Figure 6"); $stop; end
        if (DUT.MEM.mem[2] !== 16'b1101001000000110) begin err = 1; $display("FAILED: mem[2] wrong; please set data.txt using Figure 6"); $stop; end
        if (DUT.MEM.mem[3] !== 16'b1000001000100000) begin err = 1; $display("FAILED: mem[3] wrong; please set data.txt using Figure 6"); $stop; end
        if (DUT.MEM.mem[4] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using Figure 6"); $stop; end
        if (DUT.MEM.mem[5] !== 16'b1010101111001101) begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using Figure 6"); $stop; end
        // Wait until next falling edge of clock
        #10;

        // Reset de-asserted
        KEY[1] = 1'b1;
        // Waiting for RST state to cause reset of PC
        #10;

        if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

        // Wait here until PC changes
        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);

        if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

        // Wait here until PC changes
        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);

        if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end

        // Because MOV R0, X should have occurred
        if (DUT.CPU.DP.REGFILE.R0 !== 16'h5) begin err = 1; $display("FAILED: R0 should be 5."); $stop; end

        // Wait here until PC changes
        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);

        if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end

        if (DUT.CPU.DP.REGFILE.R1 !== 16'hABCD) begin err = 1; $display("FAILED: R1 should be 0xABCD. Looks like your LDR isn't working."); $stop; end

        // Wait here until PC changes
        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);

        if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end

        if (DUT.CPU.DP.REGFILE.R2 !== 16'h6) begin err = 1; $display("FAILED: R2 should be 6."); $stop; end

        // Wait here until PC changes
        @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    
        if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end

        if (DUT.MEM.mem[6] !== 16'hABCD) begin err = 1; $display("FAILED: mem[6] wrong; looks like your STR isn't working"); $stop; end

        // If HALT is working, PC won't change again

        if (~err) $display("INTERFACE OK");
        
        $stop;
    end
endmodule
