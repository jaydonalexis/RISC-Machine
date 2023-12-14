// `timescale 1ps/1ps
module regfile_tb();
    reg [15:0] sim_data_in;
    reg [2:0] sim_readnum, sim_writenum;
    reg sim_clk, sim_write;
    reg err;

    wire [15:0] sim_data_out;

    regfile DUT (
    .data_in(sim_data_in),
    .writenum(sim_writenum),
    .write(sim_write),
    .readnum(sim_readnum),
    .clk(sim_clk),
    .data_out(sim_data_out)
    );

    // One task to repeat with each register
    task checkreg;
        input [15:0] task_data_in;
        input [2:0] task_readnum; 
        input [2:0] task_writenum;
        begin
            sim_data_in = task_data_in;
            sim_write = 1'b1;
            sim_writenum = task_writenum;
            #4;

            sim_readnum = task_readnum;
            // Rising edge of clock
            #2;

            if(sim_data_out !== sim_data_in) begin
                $display("Error[%b:2]: data_out is %b, expected %b", task_readnum, sim_data_out, sim_data_in);
                err = 1'b1;
            end
            #1;

            sim_write = 1'b0;
            sim_data_in = 0;
            #3;

            if(sim_data_out == 1'd0) begin
                $display("Error[%b:3]: data_out should not have changed", task_readnum);
                err = 1'b1;
            end
            #6;

            if(sim_data_out == 1'd0) begin
                $display("Error[%b:4]: data_out should not have changed", task_readnum);
                err = 1'b1;
            end
            #4

            sim_write = 1'b1;

            #7;

            if(sim_data_out !== 1'd0) begin
                $display("Error[%b:7]: data_out is %b, expected 0", task_readnum, sim_data_out);
                err = 1'b1;
            end
            #3;
        end
    endtask

    initial begin
        sim_clk = 1'b0;

        forever begin
            #5;
            sim_clk = 1'b1;
            #5;
            sim_clk = 1'b0;
        end
    end


    initial begin
        err = 1'b0;

        checkreg(16'b0000000000101010, 3'b000, 3'b000);
        checkreg(16'b0000000000100111, 3'b001, 3'b001);
        checkreg(16'b0000000111100011, 3'b010, 3'b010);
        checkreg(16'b1001000100100010, 3'b011, 3'b011);
        checkreg(16'b0000000000000001, 3'b100, 3'b100);
        checkreg(16'b0000000000000100, 3'b101, 3'b101);
        checkreg(16'b0000000000111000, 3'b110, 3'b110);
        checkreg(16'b0001000000000000, 3'b111, 3'b111);

        if(err == 1'b0)
            $display("No Errors :)");
        $stop;
    end
endmodule
