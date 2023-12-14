// `timescale 1ps/1ps
module datapath_tb();
    reg [15:0] sim_datapath_in;
    reg [2:0] sim_readnum, sim_writenum;
    reg [1:0] sim_ALUop, sim_shift;
    reg sim_clk, sim_write, sim_vsel, sim_loada, sim_loadb, sim_asel, sim_bsel, sim_loadc, sim_loads;
    reg err;

    wire [15:0] sim_datapath_out;
    wire sim_Z_out;

    datapath DUT (
    .datapath_in(sim_datapath_in),
    .clk(sim_clk),
    .write(sim_write),
    .vsel(sim_vsel),
    .loada(sim_loada),
    .loadb(sim_loadb),
    .asel(sim_asel),
    .bsel(sim_bsel),
    .loadc(sim_loadc),
    .loads(sim_loads),
    .datapath_out(sim_datapath_out),
    .readnum(sim_readnum),
    .shift(sim_shift),
    .ALUop(sim_ALUop),
    .writenum(sim_writenum),
    .Z_out(sim_Z_out)
    );

    // This task can be used to initialize register values
    task initialiser;
        input[15:0] task_R0, task_R1, task_R2;
        begin
            sim_write = 1'b1;
            sim_vsel = 1'b1;

            sim_clk = 1'b0;

            sim_datapath_in = task_R0;
            sim_writenum = 3'b000;
            #2;

            sim_clk = 1'b1;
            #2;
            sim_clk = 1'b0;

            sim_datapath_in = task_R1;
            sim_writenum = 3'b001;
            #2;

            sim_clk = 1'b1;
            #2;
            sim_clk = 1'b0;

            sim_datapath_in = task_R2;
            sim_writenum = 3'b010;
            #2;

            sim_clk = 1'b1;
            #2;
        end
    endtask

    // Takes absolute number and stores it in the register specified
    task abs_mover;
        input [16:0] abs_number;
        input[2:0] task_register;
        begin
            sim_clk = 1'b0;

            sim_datapath_in = abs_number; 
            sim_vsel = 1'b1;
            sim_write = 1'b1;
            sim_writenum = task_register;
            #2;

            sim_clk = 1'b1;
            #2;
        end
    endtask


    // Makes dest_R the [operation] of the first R and the second R with a possible shift
    task operations;
        input [1:0] task_op;
        input [2:0] dest_R;
        input [2:0] first_R, second_R;
        input[1:0] task_shift;
        begin
            sim_asel = 1'b0;
            sim_bsel = 1'b0	;
            sim_loada = 1'b0;
            sim_loadb = 1'b0;
            sim_vsel = 1'b1;
            sim_shift = task_shift;
            sim_ALUop = task_op;
            sim_write = 1'b0;

            sim_clk = 1'b0;

            sim_readnum = first_R;
            sim_loada = 1'b1;
            #2;

            sim_clk = 1'b1;
            #2;
            sim_clk = 1'b0;

            sim_loada = 1'b0;
            sim_readnum = second_R;
            sim_loadb = 1'b1;
            #2;

            sim_clk = 1'b1;
            #2;
            sim_clk = 1'b0;

            sim_loadb = 1'b0;
            sim_loadc = 1'b1;
            #2;

            sim_clk = 1'b1;
            #2;

            $display("%b", sim_datapath_out);

            sim_clk = 1'b0;

            sim_vsel = 1'b0;
            sim_writenum = dest_R;
            sim_write = 1'b1;
            #2;

            sim_clk = 1'b1;
            #2;
        end
    endtask

// Testing begins here
    initial begin
        err = 1'b0;
        // The following is the provided test sequence involving two MOV operations and one ADD operation
        initialiser(16'b0000000000000001, 16'b0000000000000010, 16'b0000000000100111);
        abs_mover(3'b000, 16'b0000000000000111);
        abs_mover(3'b001, 16'b0000000000000010);
        operations(2'b00, 3'b010, 3'b001, 3'b000, 2'b01);

        if(datapath_tb.DUT.REGFILE.R2 !== 16'b0000000000010000) begin
            $display("Error: R2 is %b, expected 16", datapath_tb.DUT.REGFILE.R2);
            err = 1'b1;
        end

        // The following are additional test sequences
        abs_mover(3'b000, 16'b0000000000001101);
        abs_mover(3'b001, 16'b0000000000000111);
        operations(2'b01, 3'b010, 3'b000, 3'b001, 2'b10);

        if(datapath_tb.DUT.REGFILE.R2 !== 16'b0000000000001010) begin
            $display("Error: R2 is %b, expected 10", datapath_tb.DUT.REGFILE.R2);
            err = 1'b1;
        end

        abs_mover(3'b100, 16'b0000000000000110);
        abs_mover(3'b101, 16'b1000111111111111);
        operations(2'b11, 3'b111, 3'b100, 3'b101, 2'b11);

        if(datapath_tb.DUT.REGFILE.R7 !== 16'b0011100000000000) begin
            $display("Error: R8 is %b, expected 0011100000000000", datapath_tb.DUT.REGFILE.R7);
            err = 1'b1;
        end

        abs_mover(3'b011, 16'b0000000011111000);
        abs_mover(3'b100, 16'b0000000000011111);
        operations(2'b10, 3'b000, 3'b011, 3'b100, 2'b00);

        if(datapath_tb.DUT.REGFILE.R0 !== 16'b0000000000011000) begin
            $display("Error: R0 is %b, expected 000000000000011000", datapath_tb.DUT.REGFILE.R0);
            err = 1'b1;
        end

        if(err == 1'b0)
            $display("No Errors :)");
    end
endmodule

