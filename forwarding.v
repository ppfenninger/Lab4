`timescale 1 ns / 1 ps
module forwarding (
	input[4:0] targetReg,
	input[31:0] targetData,
	input[4:0] MEM_reg,
	input[31:0] MEM_data,
	input      MEM_regWr,
	input[4:0] WB_reg,
	input[31:0] WB_data,
	input       WB_regWr,
	output reg[31:0] data
);

always @(targetData or targetReg or MEM_reg or MEM_data or WB_reg or WB_data or MEM_regWr or WB_regWr) begin
	case(targetReg)
		MEM_reg: begin
			if(MEM_regWr==1'b1)
				data=MEM_data;
			else
				data=targetData; 
		end
		WB_reg: begin
			if(WB_regWr==1'b1)
				data=WB_data;
			else
				data=targetData;
		end
		default: data=targetData;
	endcase // targetReg
end

endmodule