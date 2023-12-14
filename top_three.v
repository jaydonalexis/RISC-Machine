module top_three(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input [9:0] SW;
    input [3:0] KEY;

    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire [15:0] dout, read_data, write_data;
    wire [8:0] mem_addr;
    wire [1:0] mem_cmd;
    wire enable, write;

    reg is_memory_address, is_read_command, is_write_command, TSIread, enablewrite;

    `define MNONE 2'b00
    `define MREAD 2'b01
    `define MWRITE 2'b11
    
    // Instantiation of our CPU module
    cpu CPU(.clk(~KEY[0]), .reset(~KEY[1]), .mem_cmd(mem_cmd), .mem_addr(mem_addr),
            .read_data(read_data), .out(write_data), .N(N), .V(V), .Z(Z));

    // Instantiation of ram module with the file name specified in the parameters
    ram #(16, 8, "IO_Test.txt") RAM(.clk(~KEY[0]), .read_address(mem_addr[7:0]), .write_address(mem_addr[7:0]),
                                    .write(write), .din(write_data), .dout(dout));

    // Always block that determines whether we have a valid memory address based on the eighth bit of mem_addr
    always @* begin
        if (mem_addr[8] == 1'b0)
            is_memory_address = 1'b1;
        else
            is_memory_address = 1'b0;
    end

    // Splits the memory command into 1 bit indicators for use in tri state buffers and load registers
    always @* begin
        if (mem_cmd == `MREAD) begin
            is_read_command = 1'b1;
            is_write_command = 1'b0;
        end
        else if (mem_cmd == `MWRITE) begin
            is_read_command = 1'b0;
            is_write_command = 1'b1;
        end
        else begin
            is_read_command = 1'b0;
            is_write_command = 1'b0;
        end

    // Conditions for tri state buffer wire
    if(mem_cmd == 2'b01 && mem_addr == 9'h140)
        TSIread = 1'b1;
    else
        TSIread = 1'b0;

    // Conditions for LED load register wire
    if(mem_cmd == 2'b11 && mem_addr == 9'h100)
        enablewrite = 1'b1;
    else
        enablewrite = 1'b0;
    end

    // Using the vdff register to hold LED values
    vdff_w_load #(8) WRITE_LOAD(.clock(~KEY[0]), .set(enablewrite), .din(write_data[7:0]), .dout(LEDR[7:0]));

    // Enable will allow read operation when read command and memory address are correct
    assign enable = is_read_command & is_memory_address;
    // Write will allow write opertaion when write command and memory adress are correct
    assign write = is_write_command & is_memory_address;
    // Tri state buffer with enable allowing the memory block to output value
    assign read_data = enable ? dout : {16{1'bz}};
    // Tri state buffers that determine the input from the switches
    assign read_data[7:0] = TSIread ? SW[7:0] : {8{1'bz}};
    assign read_data[15:8] = TSIread ? {8{1'b0}} : {8{1'bz}};
endmodule
