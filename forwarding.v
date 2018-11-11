`timescale 1 ns / 1 ps
module forwarding (
	input[4:0] targetReg,
	input[31:0] targetData,
	input[4:0] MEM_reg,
	input[31:0] MEM_data,
	input[4:0] WB_reg,
	input[31:0] WB_data,
	output reg[31:0] data
);

always @(targetData or targetReg) begin
	case(targetReg)
		MEM_reg: data=MEM_data;
		WB_reg: data=WB_data;
		default: data=targetData;
	endcase // targetReg
end

endmodule