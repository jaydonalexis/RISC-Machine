module top_three_tb_two();
    reg [9:0] SW;
    reg [3:0] KEY;
    reg err;
    
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    top_three DUT(.KEY(KEY), .SW(SW), .LEDR(LEDR), .HEX0(HEX0), .HEX1(HEX1),
                  .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));

    initial begin
        forever begin
            KEY[0] = 1'b1;
            #5;
            KEY[0] = 1'b0;
            #5;
        end
    end

    initial begin 
        err = 1'b0;
        KEY[1] = 1'b0;

        // Checking that the memory contains the right instructions
        if(DUT.MEM.mem[0] !== 16'b1101000000001111) begin
            err = 1'b1;
            $display("mem didnt load with correct instructions");
        end
        #10;

        KEY[1] = 1'b1;
        // MOV instruction takes 6 clock cycles starting from reset to get back to IF1
        #60;

        // Checking that we moved 15 to R0
        if(DUT.CPU.DP.REGFILE.R0 !== 16'b0000000000001111) begin
            err = 1'b1;
            $display("R0 doesnt contain 15"); 
        end
        // MOV instruction takes 5 clock cycles starting from IF1 to get back to IF1
        #50;

        // Checking that we moved 18 to R1
        if(DUT.CPU.DP.REGFILE.R1 !== 16'b0000000000010010) begin
            err = 1'b1;
            $display("R1 doesnt contain 18"); 
        end
        // ALU instructions other than CMP take 7 clock cycles starting from IF1 to get back to IF1
        #80;

        // Checking that the addition to R2 worked
        if(DUT.CPU.DP.REGFILE.R2 !== 16'b0000000000110000) begin
            err = 1'b1;
            $display("R2 doesnt contain 48"); 
        end
        // STR instruction takes 10 clock cycles starting from IF1 to get back to IF1
        #100;

        // The next instruction is to store the contents of R1 into [R2 + 1] so we check that MEM 49 contains 18 since R2 had 48
        if(DUT.MEM.mem[49]!== 16'b0000000000010010) begin
            err = 1'b1;
            $display("Error mem[49] should contain 18");
        end
        // LDR instruction takes 9 clock cycles starting from IF1 to get back to IF1
        #90;

        // The next instruction is to load the contents of [R2 + 1] back into R3
        if(DUT.CPU.DP.REGFILE.R3 !== 16'b0000000000010010) begin
            err = 1'b1;
            $display("Error, R3 should contain 18");
        end
        // The halt state takes 4 clock cycles to get to from IF1 but we set the delay to 6 clock cycles so that we can see if it stays in the halt state
        #60;

        // Here we test whether the state machine remains in the halt state
        if(DUT.CPU.controller_fsm_1.present_state !== 5'b11111) begin
            err = 1'b1;
            $display("fsm should stay in halt stage");
        end

        if(err == 1'b0)
            $display("No Errors :)");

        $stop;
    end 
endmodule
