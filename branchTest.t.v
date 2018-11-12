`include "branchTest.v"
`timescale 1 ns / 1 ps 

module branchTestTest ();
	reg[5:0] opcode;
	reg[31:0] Da, Db, initialBranchAddress;
	wire[31:0] branchAddress;

	branchTest branchTest(opcode, Da, Db, initialBranchAddress, branchAddress);

	initial begin
		$display("Starting branch test test");
		initialBranchAddress = 32'b11111111111111110000000000000000;

		//is BNE and should branch
		opcode=6'b000101; Da=32'd1; Db=32'd3; #100
		if (branchAddress !== initialBranchAddress) $display("Test 1 failed - %b", branchAddress);

		//is BNE and should not branch
		opcode=6'b000101; Da=32'd3; Db=32'd3; #100
		if (branchAddress !== 32'b0) $display("Test 2 failed - %b", branchAddress);

		//is BEQ and should branch
		opcode=6'b000100; Da=32'd3; Db=32'd3; #100
		if (branchAddress !== initialBranchAddress) $display("Test 3 failed - %b", branchAddress);

		//is BEQ and should not branch
		opcode=6'b000100; Da=32'd1; Db=32'd3; #100
		if (branchAddress !== 32'b0) $display("Test 4 failed - %b", branchAddress);

		//is not BNE or BEQ
		opcode=6'b000000; Da=32'd1; Db=32'd3; #100
		if (branchAddress !== 32'b0) $display("Test 5 failed - %b", branchAddress);

		$display("Finished branch test test");
	end

endmodule