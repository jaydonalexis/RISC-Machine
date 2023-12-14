module cpu(clk, reset, mem_cmd, mem_addr, out, read_data, N, V, Z);
    input [15:0] read_data;
    input clk, reset;

    output [15:0] out;
    output [8:0] mem_addr;
    output [1:0] mem_cmd;
    output N, V, Z;

    wire [15:0] instruc, sximm8, sximm5;
    wire [8:0] PC, data_address_out, increment_out;
    wire [3:0] vsel;
    wire [2:0] opcode, writenum, readnum, nsel;
    wire [1:0] op, shift, ALUop;
    wire write, loadb, loada, asel, bsel, loadc, loads, load_ir, load_pc, reset_pc, addr_sel, load_addr;

    reg [8:0] next_pc, mem_addr;

    // Instantiating our instruction register which will store our input instructions
    instruc_reg INSTRUC_REG(.clk(clk), .in(read_data), .load(load_ir), .out(instruc));

    // Instantiating our instruction decoder which will take our instruction bit field and dissect them into their respective external module inputs
    instruc_dec INSTRUC_DEC(.in(instruc), .opcode(opcode), .op(op), .nsel(nsel),
                            .writenum(writenum), .readnum(readnum), .shift(shift), 
                            .sximm8(sximm8), .sximm5(sximm5), .ALUop(ALUop));

    // Responsible for computation and storage
    datapath DATAPATH(.clk(clk), .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb),
                      .shift(shift), .asel(asel), .bsel(bsel), .ALUop(ALUop), .loadc(loadc),
                      .loads(loads), .writenum(writenum), .write(write), .sximm8(sximm8),
                      .sximm5(sximm5), .Z_out({N, V, Z}), .datapath_out(out),
                      .mdata(read_data), .PC(PC));

    //Responsible for providing the outputs that control IR, PCR, ID, DP, etc.
    controller_fsm CONTROLLER_FSM(.mem_cmd(mem_cmd), .load_pc(load_pc), .load_ir(load_ir),
                                  .reset_pc(reset_pc), .addr_sel(addr_sel), .reset(reset), .opcode(opcode), .op(op),
                                  .nsel(nsel), .vsel(vsel), .write(write), .loadb(loadb), .loada(loada),
                                  .asel(asel), .bsel(bsel), .loadc(loadc), .loads(loads),
                                  .load_addr(load_addr), .clk(clk));

    // Requires a register w load enable to store the PC
    vdff_w_load #(9) PROGRAM_COUNTER(.clock(clk), .set(load_pc), .din(next_pc), .dout(PC));
    
    // Requires a register w load enable to store the address
    vdff_w_load #(9) DATA_ADDRESS(.clock(clk), .set(load_addr), .din(out[8:0]), .dout(data_address_out));

    // Reset PC multiplexer
    always @* begin
        case(reset_pc)
            1'b1: next_pc <= 9'b000000000;
            1'b0: next_pc <= increment_out;
            default: next_pc = 9'bxxxxxxxxx;
        endcase
    end

    // Implementing the address selection register
    always @* begin
        case(addr_sel)
            1'b1: mem_addr <= PC;
            1'b0: mem_addr <= data_address_out;
            default: mem_addr = 9'bxxxxxxxxx;
        endcase
    end

    // On the rising edge of the clock, the PC register now holds the former PC value + 1 if load_pc is enabled
    assign increment_out = PC + 9'b000000001;
endmodule

