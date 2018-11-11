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
	input[31:0] initiaInstruction,
	input ID_NoOp,
	input ID_PreNoOp,
	output[31:0] instr,
	output IF_NoOp,
	output IF_PreNoOp
);

reg isJR, isOtherBranch;
wire[31:0] noOPInstr;
wire[5:0] opcode;
wire[5:0] funct;
wire ID_NoOpInv;
wire ID_PreNoOpInv;
wire beginJRProcess;

assign noOPInstr = 32'b00100000000000000000000000000000;

not(ID_NoOpInv, ID_NoOp);
not(ID_PreNoOpInv, ID_PreNoOp);


always @(instruction) begin
	opcode = instruction[31:26];
	funct = instruction[5:0];
	case (opcode)
		`LW_OP:   begin isJR=0; isOtherBranch=1; end
		`SW_OP:   begin isJR=0; isOtherBranch=0; end //SW
		`J_OP:    begin isJR=0; isOtherBranch=0; end //J
		`JAL_OP:  begin isJR=0; isOtherBranch=0; end //JAL
		`BEQ_OP:  begin isJR=0; isOtherBranch=1; end //BEQ
		`BNE_OP:  begin isJR=0; isOtherBranch=1; end//BNE
		`XORI_OP: begin isJR=0; isOtherBranch=0; end //XORI
		`ADDI_OP: begin isJR=0; isOtherBranch=0; end //ADDI

		`RTYPE_OP: begin
			case (funct)
				`JR_FUNCT:  begin isJR=1; isOtherBranch=0; end //JR
				`ADD_FUNCT: begin isJR=0; isOtherBranch=0; end //ADD
				`SUB_FUNCT: begin isJR=0; isOtherBranch=0; end //SUB //actually is subtract
				`SLT_FUNCT: begin isJR=0; isOtherBranch=0; end//SLT //actually is subtract
				default: $display("Error in No-Op: Invalid funct");
			endcase
		end
		default: $display("Error in No-Op: Invalid opcode. OPCODE: %b", opcode);
	endcase

	and(beginJRProcess, isJR, ID_PreNoOpInv, ID_NoOpInv);

	if(beginJRProcess) begin instr = noOPInstr; IF_PreNoOp = 1; IF_NoOp = 0; end
	else if(ID_PreNoOp) begin instr = initiaInstruction; IF_PreNoOp = 0; IF_NoOp = 1; end
	else if(ID_NoOp) begin instr = noOPInstr; IF_PreNoOp = 0; IF_NoOp = 0; end
	else if(isOtherBranch) begin instr = initiaInstruction; IF_PreNoOp = 0; IF_NoOp = 1; end
	else begin instr = initiaInstruction; IF_PreNoOp = 0; IF_NoOp = 0; end
end
endmodule // noOp