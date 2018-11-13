`define LW_OP    6'b100011
`define SW_OP    6'b101011
`define J_OP     6'b000010
`define JAL_OP   6'b000011
`define BEQ_OP   6'b000100
`define BNE_OP   6'b000101
`define XORI_OP  6'b001110
`define ADDI_OP  6'b001000
`define RTYPE_OP 6'b000000

`define JR_FUNCT  6'b001000
`define ADD_FUNCT 6'b100000
`define SUB_FUNCT 6'b100010
`define SLT_FUNCT 6'b101010

`timescale 1 ns / 1 ps

module jumpTest (
	input[31:0] instruction,
	input[31:0] programCounter,
	output reg[31:0] jumpAddress,
	output reg doesJump
);

reg[5:0] opcode;

always @(instruction) begin
	opcode = instruction[31:26];
	case (opcode)
		`LW_OP:   begin doesJump=0; end
		`SW_OP:   begin doesJump=0; end //SW
		`J_OP:    begin doesJump=1; end //J
		`JAL_OP:  begin doesJump=1; end //JAL
		`BEQ_OP:  begin doesJump=0; end //BEQ
		`BNE_OP:  begin doesJump=0; end//BNE
		`XORI_OP: begin doesJump=0; end //XORI
		`ADDI_OP: begin doesJump=0; end //ADDI
		`RTYPE_OP: begin doesJump=0;
		end
		default: $display("Error in jump test: Invalid opcode. OPCODE: %b", opcode);
	endcase

	jumpAddress = {programCounter[29:26], instruction[25:0],2'b00};
end

endmodule