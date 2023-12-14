module ram(clk, read_address, write_address, write, din, dout);
    parameter data_width = 32;
    parameter addr_width = 4;
    parameter filename = "data.txt";

    input clk;
      input [addr_width-1:0] read_address, write_address;
      input write;
      input [data_width-1:0] din;

      output [data_width-1:0] dout;

      reg [data_width-1:0] dout;
    reg [data_width-1:0] mem [2**addr_width-1:0];

    initial $readmemb(filename, mem);

    always @ (posedge clk) begin
        if (write) begin
            mem[write_address] <= din;
        end

        dout <= mem[read_address]; 
    end 
endmodule
