`include "no-op.v"
`timescale 1 ns / 1 ps

module testNoOp();
    reg[31:0] initialInstruction;
    reg ID_noOp, ID_preNoOp;
    wire[31:0] instr; 
    wire IF_noOp, IF_prenoOp;

    noOp noOp(initialInstruction, ID_noOp, ID_preNoOp, instr, IF_noOp, IF_prenoOp);

    initial begin
    	$display("Starting No Op Test");

        //Is JR
        initialInstruction=32'b00000011111111111111111111001000; ID_noOp=0; ID_preNoOp=0; #100
        if (instr !== 32'b00100000000000000000000000000000) $display("Test 1a failed - %b", instr);
        if (IF_noOp !== 0) $display("Test 1b failed - %b", IF_noOp);
        if (IF_prenoOp !== 1) $display("Test 1c failed - %b", IF_prenoOp);

        //Pre No-Op is high
        initialInstruction=32'b00000011111111111111111111001000; ID_noOp=0; ID_preNoOp=1; #100
        if (instr !== initialInstruction) $display("Test 2a failed - %b", instr);
        if (IF_noOp !== 1) $display("Test 2b failed - %b", IF_noOp);
        if (IF_prenoOp !== 0) $display("Test 2c failed - %b", IF_prenoOp);

        //No-op is high
        initialInstruction=32'b00000011111111111111111111001000; ID_noOp=1; ID_preNoOp=0; #100
        if (instr !== 32'b00100000000000000000000000000000) $display("Test 3a failed - %b", instr);
        if (IF_noOp !== 0) $display("Test 3b failed - %b", IF_noOp);
        if (IF_prenoOp !== 0) $display("Test 3c failed - %b", IF_prenoOp);

        //Its one of the other should no-op things
        initialInstruction=32'b10001111111111111111111111001000; ID_noOp=0; ID_preNoOp=0; #100 //LW - 100011
        if (instr !== initialInstruction) $display("Test 4a failed - %b", instr);
        if (IF_noOp !== 1) $display("Test 4b failed - %b", IF_noOp);
        if (IF_prenoOp !== 0) $display("Test 4c failed - %b", IF_prenoOp);

        //It should not no-op
        initialInstruction=32'b00100011111111111111111111001000; ID_noOp=0; ID_preNoOp=0; #100 //ADDI
        if (instr !== initialInstruction) $display("Test 5a failed - %b", instr);
        if (IF_noOp !== 0) $display("Test 5b failed - %b", IF_noOp);
        if (IF_prenoOp !== 0) $display("Test 5c failed - %b", IF_prenoOp);

    	$display("Finish No Op Test");
	end


endmodule // testNoOp
