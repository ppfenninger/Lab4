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

module noOp(
	input[5:0] opcode,
	input[5:0] funct,
	input previousNoOp,
	output isNoOp
);

reg shouldBeNoOp;
wire previousNoOpInv;

always @(opcode or funct) begin
	case (opcode)
		`LW_OP:   begin shouldBeNoOp=1; end
		`SW_OP:   begin shouldBeNoOp=0; end //SW
		`J_OP:    begin shouldBeNoOp=0; end //J
		`JAL_OP:  begin shouldBeNoOp=0; end //JAL
		`BEQ_OP:  begin shouldBeNoOp=1; end //BEQ
		`BNE_OP:  begin shouldBeNoOp=1; end//BNE
		`XORI_OP: begin shouldBeNoOp=0; end //XORI
		`ADDI_OP: begin shouldBeNoOp=0; end //ADDI

		`RTYPE_OP: begin
			case (funct)
				`JR_FUNCT: begin shouldBeNoOp=1; end //JR
				`ADD_FUNCT: begin shouldBeNoOp=0; end //ADD
				`SUB_FUNCT: begin shouldBeNoOp=0; end //SUB //actually is subtract
				`SLT_FUNCT: begin shouldBeNoOp=0; end//SLT //actually is subtract
				default: $display("Error in No-Op: Invalid funct");
			endcase
		end
		default: $display("Error in No-Op: Invalid opcode. OPCODE: %b", opcode);
	endcase
end

not(previousNoOpInv, previousNoOp);
and(isNoOp, previousNoOpInv, shouldBeNoOp);

endmodule // noOp