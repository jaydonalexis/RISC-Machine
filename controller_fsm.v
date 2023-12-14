module controller_fsm(mem_cmd, load_pc, load_ir, reset_pc, addr_sel, load_addr, clk, reset, opcode, op, nsel, vsel, write, loada, loadb, asel, bsel, loadc, loads);
    input [2:0] opcode;
    input [1:0] op;
    input reset, clk;

    output [3:0] vsel;
    output [2:0] nsel;
    output [1:0] mem_cmd;
    output write, loada, loadb, asel, bsel, loadc, loads, load_pc, load_ir, reset_pc, addr_sel, load_addr;

    `define MNONE 2'b00
    `define MREAD 2'b01
    `define MWRITE 2'b11

    `define RST 5'b00000
    `define IF1 5'b00001
    `define IF2 5'b00010
    `define UPDATE_PC 5'b00011
    `define DECODE 5'b00100
    `define GET_A 5'b00101
    `define GET_B 5'b00110
    `define ARITHMETIC 5'b00111
    `define WRITE_REG 5'b01000
    `define MOV_IMM 5'b01001
    `define MOV_REG_ONE 5'b01010
    `define MOV_REG_TWO 5'b01011
    `define MOV_REG_THREE 5'b01100
    `define COMPARE 5'b01101
    `define ARITHMETIC_TWO 5'b01110
    `define BUFF_ONE 5'b01111
    `define BUFF_TWO 5'b10000
    `define LOAD 5'b10001
    `define STR_ONE 5'b10010
    `define STR_TWO 5'b10011
    `define STR_VAL 5'b10100
    `define HALT 5'b11111

    wire [4:0] present_state, state_next_reset, state_next;

    reg [25:0] next;

    vdff #(5) STATE(.clk(clk), .in(state_next_reset), .out(present_state));

    // Checks to see if reset is high, in which case we reset
    assign state_next_reset = reset ? `RST : state_next;

    // Continuously updates present state and outputs based on the past state and inputs
    always @* begin
        // Checking state and inputs
        casex({present_state, op, opcode})
            // Reset state where we will reset the program counter by loading all 0's into the PC register
            {`RST, 2'bxx, 3'bxxx}: next <= {`IF1, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, `MNONE, 1'b0, 1'b0};
            // First stage of instruction fetch. PC register contains the address of the next instruction in RAM and we select this in the multiplexer
            {`IF1, 2'bxx, 3'bxxx}: next <= {`IF2, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, `MREAD, 1'b0, 1'b0};
            // Second stage in which the contents of the read address now appear on the read_data line. The instruction register is loaded with this information/command
            {`IF2, 2'bxx, 3'bxxx}: next <= {`UPDATE_PC, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, `MREAD, 1'b1, 1'b0};
            // next_pc already had the address of the next instruction to be executed so we clock to load this new address into the PC register
            {`UPDATE_PC, 2'bxx, 3'bxxx}: next <= {`DECODE, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, `MNONE, 1'b0, 1'b0};
            /*
            * String of DECODE stages. If the opcode is 101, 011 or 100, we move to GET_A which is a common starting point
            * for the ALU, LDR and STR instructions. If the opcode is 110, we move to either the starting state of move immediate
            * or move register contents based on the opcode given. Finally, if the opcode is 111, we go to the HALT state
            */
            {`DECODE, 2'bxx, 3'b101}: next <= {`GET_A, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            {`DECODE, 2'bxx, 3'b011}: next <= {`GET_A, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            {`DECODE, 2'bxx, 3'b100}: next <= {`GET_A, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            {`DECODE, 2'b10, 3'b110}: next <= {`MOV_IMM, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            {`DECODE, 2'b00, 3'b110}: next <= {`MOV_REG_ONE, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            {`DECODE, 2'bxx, 3'b111}: next <= {`HALT, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            // Halt state which will cause the PC to no longer be updated. Can only leave this state with a rising edge on rst
            {`HALT, 2'bxx, 3'bxxx}: next <= {`HALT, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            /*
            * A string of GET_A states due to the fact that there were multiple paths to this state from the DECODE stage.
            * Once again, depending on the opcode given, we either go to GET_B which sets our path in the ALU stage or ARITHMETIC_TWO
            * where our path will be set to either a load or a store
            */
            {`GET_A, 2'bxx, 3'b101}: next <= {`GET_B, 4'bxxxx, 3'b100, 1'b0, 1'b0, 1'b1, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'bx, `MNONE, 1'b0, 1'b0};
            {`GET_A, 2'bxx, 3'b011}: next <= {`ARITHMETIC_TWO, 4'bxxxx, 3'b100, 1'b0, 1'b0, 1'b1, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'bx, `MNONE, 1'b0, 1'b0};
            {`GET_A, 2'bxx, 3'b100}: next <= {`ARITHMETIC_TWO, 4'bxxxx, 3'b100, 1'b0, 1'b0, 1'b1, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'bx, `MNONE, 1'b0, 1'b0};
            /*
            * A string of GET_B states all within the ALU instruction path. There are 4 because if the opcode is 01, then we jump to a COMPARE stage
            * which is unique to that specific opcode. Therefore, we cannot apply 2'bxx for the opcode in this regard
            */
            {`GET_B, 2'b00, 3'bxxx}: next <= {`ARITHMETIC, 4'bxxxx, 3'b001, 1'b0, 1'b1, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            {`GET_B, 2'b10, 3'bxxx}: next <= {`ARITHMETIC, 4'bxxxx, 3'b001, 1'b0, 1'b1, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            {`GET_B, 2'b11, 3'bxxx}: next <= {`ARITHMETIC, 4'bxxxx, 3'b001, 1'b0, 1'b1, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            {`GET_B, 2'b01, 3'bxxx}: next <= {`COMPARE, 4'bxxxx, 3'b001, 1'b0, 1'b1, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            // Basic ARITHMETIC stage for the ALU instruction path. In this state, operations will only be performed on loaded values from the register file
            {`ARITHMETIC, 2'bxx, 3'bxxx}: next <= {`WRITE_REG, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b1};
            // Final stage of the ALU instruction path in which the result stored in the C register is written to a register in the register file
            {`WRITE_REG, 2'bxx, 3'bxxx}: next <= {`IF1, 4'b0001, 3'b010, 1'b1, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            /*
            * Only stage in the move immmediate instruction path after DECODE. The immediate value is stored within the instruction itself and all that is
            * done here is a selection at the input mux of the register file to load this immediate value into the appropriate register
            */
            {`MOV_IMM, 2'bxx, 3'bxxx}: next <= {`IF1, 4'b0100, 3'b100, 1'b1, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            /*
            * The ARITHMETIC stage for the LDR/STR instruction path. At this point we have already retrieved the contents of register Rn and are storing the result
            * of its addition to sximm5 in the C register. On the rising edge of the clock, this content will be on datapath_out
            */
            {`ARITHMETIC_TWO, 2'bxx, 3'bxxx}: next <= {`BUFF_ONE, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            /*
            * Two BUFF_ONE states from which we will either branch to the LDR or STR instruction paths depending on the opcode. At this point we set load_addr to 1
            * since we need to store a portion of the contents of datapath_out in the data address register. Also addr_sel is 0 as it also is in the following state
            * since we would like to pass the output of this register to the mem_addr line
            */
            {`BUFF_ONE, 2'bxx, 3'b011}: next <= {`BUFF_TWO, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b1};
            {`BUFF_ONE, 2'bxx, 3'b100}: next <= {`STR_ONE, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b1};
            /*
            * Now we are held within the LDR instruction path. We output a MEM command of read so that we can read the data corresponding to the given address.
            * The data read from memory will appear on the read_data line. 
            */	
            {`BUFF_TWO, 2'bxx, 3'bxxx}: next <= {`LOAD, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MREAD, 1'b0, 1'b0};
            /*
            * The data now appears on the read_data line and we choose vsel such that this line is the input to the register file. We store the result
            * in the register specified as Rd
            */
            {`LOAD, 2'bxx, 3'bxxx}: next <= {`IF1, 4'b1000, 3'b010, 1'b1, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MREAD, 1'b0, 1'b0};
            /* 
            * Now we are held within the STR path. At this point, we have stored the address and it is on the read/write address line.
            * Register B is loaded with the contents of the register specified as Rd
            */
            {`STR_ONE, 2'bxx, 3'bxxx}: next <= {`STR_TWO, 4'bxxxx, 3'b010, 1'b0, 1'b1, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            // In this stage, we set asel as 1 since we do not want to alter the contents of Rd on its way to the output of register C
            {`STR_TWO, 2'bxx, 3'bxxx}: next <= {`STR_VAL, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            /* 
            * At this point c has been loaded with the contents of the register and these contents appear on datapath_out.
            * We set the MEM command to write so that we can write this data into the address that was previously held on the
            * write_address line
            */
            {`STR_VAL, 2'bxx, 3'bxxx}: next <= {`IF1, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MWRITE, 1'b0, 1'b0};
            // First stage of moving register contents to another register. We set loadb to 1 since we have the option to perform shift operations and so on
            {`MOV_REG_ONE, 2'bxx, 3'bxxx}: next <= {`MOV_REG_TWO, 4'bxxxx, 3'b001, 1'b0, 1'b1, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            // Now that b is loaded, we set asel to 1 since we want to preserve the value of the contents in register b
            {`MOV_REG_TWO, 2'bxx, 3'bxxx}: next <= {`MOV_REG_THREE, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            // Now the contents of the read register appear on datapath_out and we select vsel accordingly to select this as the input to our register file to move to the specified register
            {`MOV_REG_THREE, 2'bxx, 3'bxxx}: next <= {`IF1, 4'b0001, 3'b010, 1'b1, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            /*
            * This is our COMPARE stage which branches from our GET_B stage as outlined earlier. Basically this extra state has been added to ensure that no register is written to when we COMPARE
            * two values, so we set write to 0 unlike in the regular write_reg which has write set to 1
            */
            {`COMPARE, 2'bxx, 3'bxxx}: next <= {`IF1, 4'bxxxx, 3'bxxx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, `MNONE, 1'b0, 1'b0};
            default: next = {26{1'bx}};
        endcase
    end

    // Assigning all of the FSM outputs from the next input
    assign {state_next, vsel, nsel, write, loadb, loada, asel, bsel, loadc, loads, reset_pc, load_pc, addr_sel, mem_cmd, load_ir, load_addr} = next;
endmodule
        