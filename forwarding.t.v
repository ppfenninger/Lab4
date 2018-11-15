`include "forwarding.v"
`timescale 1 ns / 1 ps
module forwardingTest();
	reg[31:0] targetData, MEM_data, WB_data;
	reg[4:0] targetReg, MEM_reg, WB_reg;
	reg MEM_regWr, WB_regWr;
	wire[31:0] data;
	forwarding forwarding(targetReg, targetData, MEM_reg, MEM_data, MEM_regWr, WB_reg, WB_data, WB_regWr, data);

	initial begin
		$display("Starting forwarding testing");
		//Writes are enabled - values should change when appropriate
		MEM_regWr=1; WB_regWr=1; 
		MEM_data=32'd1; WB_data=32'd2;
		MEM_reg=5'b10000; WB_reg=5'b00001;

		//target reg does not equal the other two
		targetReg=5'b10101; targetData=32'd3; #100
		if(data !== 32'd3) $display("Test 1 failed - %d", data);

		//target reg is equal to mem reg
		targetReg=5'b10000; targetData=32'd3; #100
		if(data !== 32'd1) $display("Test 2 failed - %d", data);

		//target reg is equal to wb reg
		targetReg=5'b00001; targetData=32'd3; #100
		if(data !== 32'd2) $display("Test 3 failed - %d", data);

		WB_reg=5'b10000;
		//target reg is equal to both mem reg and wb reg - should be set to mem
		targetReg=10000; targetData=32'd3; #100
		if(data !== 32'd1) $display("Test 4 failed - %d", data);


		//Writes are disabled - values should NEVER change
		MEM_regWr=0; WB_regWr=0; 
		MEM_data=32'd1; WB_data=32'd2;
		MEM_reg=5'b10000; WB_reg=5'b00001;

		//target reg does not equal the other two
		targetReg=5'b10101; targetData=32'd3; #100
		if(data !== 32'd3) $display("Test 5 failed - %d", data);

		//target reg is equal to mem reg
		targetReg=5'b10000; targetData=32'd3; #100
		if(data !== 32'd3) $display("Test 6 failed - %d", data);

		//target reg is equal to wb reg
		targetReg=5'b00001; targetData=32'd3; #100
		if(data !== 32'd3) $display("Test 7 failed - %d", data);

		WB_reg=5'b10000;
		//target reg is equal to both mem reg and wb reg - should be set to mem
		targetReg=10000; targetData=32'd3; #100
		if(data !== 32'd3) $display("Test 8 failed - %d", data);

		$display("Finished forwarding testing");
	end

endmodule