`include "jumpTest.v"
`timescale 1 ns / 1 ps

module jumpTestTest ();
	reg[31:0] instruction, programCounter;
	wire[31:0] jumpAddress;
	wire doesJump;

	jumpTest jumpTest(instruction, programCounter, jumpAddress, doesJump);

	initial begin
		$display("Starting Jump Test Test");

		programCounter = 32'b10111111111111111111111111111111;

		//is jump
		instruction=32'b00001011111111111111111111111110; #100
		if (doesJump !== 1) $display("Test 1a failed");
		if (jumpAddress !== 32'b11111111111111111111111111111000) $display("Test 1b failed - %b", jumpAddress);

		//is not jump
		instruction=32'b00100011111111111111111111111110; #100
		if (doesJump !== 0) $display("Test 2a failed");

		$display("Finished Jump Test Test");
	end

endmodule