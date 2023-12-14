// `timescale 1ps/1ps
module shifter_tb();
    reg [15:0] sim_in;
    reg [1:0] sim_shift;
    reg err;

    wire [15:0] sim_sout;

    shifter DUT (
    .in(sim_in),
    .shift(sim_shift),
    .sout(sim_sout)
    );

    initial begin
        err = 1'b0;
        sim_in = 16'b1000001011000101;
        sim_shift = 2'b00;
        #5;

        if(sim_sout !== sim_in) begin
            $display("Error[00]: sout is %b, expected 1000001011000101", sim_sout);
            err = 1'b1;
        end

        sim_shift = 2'b01;
        #5;

        if(sim_sout !== 16'b0000010110001010) begin
            $display("Error[01]: sout is %b, expected 0000010110001010", sim_sout);
            err = 1'b1;
        end

        sim_shift = 2'b10;
        #5;

        if(sim_sout !== 16'b0100000101100010) begin
            $display("Error[10]: sout is %b, expected 01000001011000101", sim_sout);
            err = 1'b1;
        end

        sim_shift = 2'b11;
        #5;

        if(sim_sout !== 16'b1100000101100010) begin
            $display("Error[11]: sout is %b, expected 1100000101100010", sim_sout);
            err = 1'b1;
        end

        #5;

        if(err == 1'b0)
            $display("No Errors :)");
    end
endmodule

