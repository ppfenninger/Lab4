`define LW_OP    6'b100011
`define SW_OP    6'b101011
`define J_OP     6'b000010
`define JAL_OP   6'b000011
`define BEQ_OP   6'b000100
`define BNE_OP   6'b000101
`define XORI_OP  6'b001110
`define ADDI_OP  6'b001000
`define RTYPE_OP 6'b000000

`timescale 1 ns / 1 ps

module branchTest (
	input[5:0] opcode,
	input[31:0] Da,
	input[31:0] Db,
	input[31:0] initialBranchAddress,
	output[31:0] branchAddress
);
reg isBNE;
reg isBEQ;

wire[31:0] doesBranch;
wire doesBranchFinal; 
wire doesBranchFinalInv;

wire isBNEFinal;
wire isBEQFinal;

and(isBNEFinal, isBNE, doesBranchFinal);
and(isBEQFinal, isBEQ, doesBranchFinalInv);

wire goToBranch;

always @(opcode) begin
	case (opcode)
		`LW_OP:   begin isBNE=0; isBEQ=0; end
		`SW_OP:   begin isBNE=0; isBEQ=0; end //SW
		`J_OP:    begin isBNE=0; isBEQ=0; end //J
		`JAL_OP:  begin isBNE=0; isBEQ=0; end //JAL
		`BEQ_OP:  begin isBNE=0; isBEQ=1; end //BEQ
		`BNE_OP:  begin isBNE=1; isBEQ=0; end//BNE
		`XORI_OP: begin isBNE=0; isBEQ=0; end //XORI
		`ADDI_OP: begin isBNE=0; isBEQ=0; end //ADDI

		`RTYPE_OP: begin isBNE=0; isBEQ=0; end
		default: $display("Error in Branch Test: Invalid opcode. OPCODE: %b", opcode);
	endcase
end

or doesBranchOR(doesBranchFinal, doesBranch[0], doesBranch[1], doesBranch[2], doesBranch[3], doesBranch[4], doesBranch[5], doesBranch[6], doesBranch[7], doesBranch[8], doesBranch[9], doesBranch[10], doesBranch[11], doesBranch[12], doesBranch[13], doesBranch[14], 
    doesBranch[15], doesBranch[16], doesBranch[17], doesBranch[18], doesBranch[19], doesBranch[20], doesBranch[21], doesBranch[22], doesBranch[23], doesBranch[24], doesBranch[25], doesBranch[26], doesBranch[27], doesBranch[28], doesBranch[29], doesBranch[30], doesBranch[31]);


generate
    genvar i;
    for (i=0; i<32; i=i+1)
    begin
        xor(doesBranch[i], Da[i], Db[i]);
        and(branchAddress[i], goToBranch, initialBranchAddress[i]); // is zero if the program shouldn't go to branch. 
    end
endgenerate

or(doesBranchFinal, doesBranch[0], doesBranch[1], doesBranch[2], doesBranch[3], doesBranch[4], doesBranch[5], doesBranch[6], doesBranch[7], doesBranch[8], doesBranch[9], doesBranch[10], doesBranch[11], doesBranch[12], doesBranch[13], doesBranch[14], 
    doesBranch[15], doesBranch[16], doesBranch[17], doesBranch[18], doesBranch[19], doesBranch[20], doesBranch[21], doesBranch[22], doesBranch[23], doesBranch[24], doesBranch[25], doesBranch[26], doesBranch[27], doesBranch[28], doesBranch[29], doesBranch[30], doesBranch[31]);
not(doesBranchFinalInv, doesBranchFinal);

or(goToBranch, isBNEFinal, isBEQFinal);

endmodule