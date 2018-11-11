`include "no-op.v"
`timescale 1 ns / 1 ps

module testNoOp();
	reg[5:0] opcode;
    reg[5:0] funct;
    reg previousNoOp;
    wire isNoOp;

    noOp noOp(opcode, funct, previousNoOp, isNoOp);

    initial begin
    	$display("Starting No Op Test");
    	opcode=`LW_OP; funct=`JR_FUNCT; previousNoOp=0; #10
    	if (isNoOp !== 1) $display("LW 1 Failed");
    	previousNoOp=1; #10
    	if (isNoOp !== 0) $display("LW 2 Failed");
    	opcode=`SW_OP; previousNoOp=0;
    	if (isNoOp !== 0) $display("SW 1 Failed");
    	previousNoOp=1; #10
    	if (isNoOp !== 0) $display("SW 2 Failed");

    	$display("Finish No Op Test");
	end


endmodule // testNoOp
