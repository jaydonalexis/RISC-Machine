// `timescale 1ps/1ps
module alu_tb();
    reg [15:0] sim_Ain, sim_Bin;
    reg [1:0] sim_ALUop;
    reg err;

    wire [15:0] sim_out;
    wire sim_Z;
    
    alu DUT (
    .Ain(sim_Ain),
    .Bin(sim_Bin),
    .ALUop(sim_ALUop),
    .out(sim_out),
    .Z(sim_Z)
    );

    initial begin
        err = 1'b0;
        sim_Ain = 16'b0000000000001101;
        sim_Bin = 16'b0000000000000110;
        sim_ALUop = 2'b00;

        #1;
        if(sim_out !== 16'b0000000000010011) begin
            $display("Error[ADD]: out is %b, expected 19", sim_out);
            err = 1'b1;
        end
        #5;

        sim_ALUop = 2'b01;

        #1;
        if(sim_out !== 16'b0000000000000111) begin
            $display("Error[SUB]: out is %b, expected 7", sim_out);
            err = 1'b1;
        end
        #5;

        sim_ALUop = 2'b10;

        #1;
        if(sim_out !== 16'b0000000000000100) begin
            $display("Error[AND]: out is %b, expected 0100", sim_out);
            err = 1'b1;
        end
        #5;

        sim_ALUop = 2'b11;

        #1;
        if(sim_out !== 16'b1111111111111001) begin
            $display("Error[NOT]: out is %b, expected 001", sim_out);
            err = 1'b1;
        end
        #5;

        sim_Bin = 16'b1111111111111111;

        #1; 
        if(sim_out !== 16'b0000000000000000) begin
            $display("Error[NOT]: out is %b, expected all 1s", sim_out);
            err = 1'b1;
        end

        if(sim_Z !== 1'b1) begin
            $display("Error[Z]: Z is 0, expected 1");
            err = 1'b1;
        #5;
        end

        if(err == 1'b0)
            $display("No Errors :)");
        #5;
    end
endmodule
