`include "regfile.v"
`include "memReg.v"
`include "adder.v"
`include "mux.v"
`include "no-op.v"
`include "branchTest.v"
`include "alu.v"
`include "regWrLUT.v"
`include "jumpTest.v"
`include "forwarding.v"
`define NOP 32'b00100000000000000000000000000000

module CPU (
	input clk,
	input reset
);

/******************************************************************************
****************************** INSTRUCTION FETCH ******************************
******************************************************************************/

// Program counter and reset
reg[31:0] IF_programCounter;
wire[31:0] IF_nextProgramCounter;

always @(posedge clk) begin
	if (reset) IF_programCounter <= 32'b0;
	else IF_programCounter <= IF_nextProgramCounter;
end

wire[31:0] IF_PCplusFour;
Adder IF_PCAdder(
	.operandA(IF_programCounter),
	.operandB(32'd4),
	.result(IF_PCplusFour),
	.carryout(),
	.overflow()
);

wire[31:0] IF_jumpAddress;
wire[31:0] IF_jumpOrPCplusFour;
wire[31:0] IF_instr;
wire IF_isJump;
jumpTest IF_jumpTest(
	.instruction(IF_instr),
	.programCounter(IF_programCounter),
	.jumpAddress(IF_jumpAddress),
	.doesJump(IF_isJump)
);

mux #(32) IF_jumpMux(
	.input0(IF_PCplusFour),
	.input1(IF_jumpAddress),
	.out(IF_jumpOrPCplusFour),
	.sel(IF_isJump)
);

wire IF_isNoOp;
wire[31:0] IF_noOpOrPCplusFour;
wire IF_noOp, IF_preNoOp;
reg ID_noOp, ID_preNoOp;
or IF_isNoOpOr(IF_isNoOp, IF_preNoOp, ID_noOp);
mux #(32) IF_noOpMux(
	.input0(IF_jumpOrPCplusFour),
	.input1(IF_programCounter),
	.out(IF_noOpOrPCplusFour),
	.sel(IF_isNoOp)
);

wire[31:0] ID_JRorBranchAddr; // Declared here for the sake of module definitions
wire IF_branchOrResult;
or IF_branchOr(IF_branchOrResult, ID_JRorBranchAddr[0], ID_JRorBranchAddr[1], ID_JRorBranchAddr[2], ID_JRorBranchAddr[3], ID_JRorBranchAddr[4], ID_JRorBranchAddr[5], ID_JRorBranchAddr[6], ID_JRorBranchAddr[7], ID_JRorBranchAddr[8], ID_JRorBranchAddr[9], ID_JRorBranchAddr[10], ID_JRorBranchAddr[11], ID_JRorBranchAddr[12], ID_JRorBranchAddr[13], ID_JRorBranchAddr[14], 
    ID_JRorBranchAddr[15], ID_JRorBranchAddr[16], ID_JRorBranchAddr[17], ID_JRorBranchAddr[18], ID_JRorBranchAddr[19], ID_JRorBranchAddr[20], ID_JRorBranchAddr[21], ID_JRorBranchAddr[22], ID_JRorBranchAddr[23], ID_JRorBranchAddr[24], ID_JRorBranchAddr[25], ID_JRorBranchAddr[26], ID_JRorBranchAddr[27], ID_JRorBranchAddr[28], ID_JRorBranchAddr[29], ID_JRorBranchAddr[30], ID_JRorBranchAddr[31]);
mux #(32) IF_branchMux(
	.input0(IF_noOpOrPCplusFour),
	.input1(ID_JRorBranchAddr),
	.out(IF_nextProgramCounter),
	.sel(IF_branchOrResult)
);

wire[31:0] IF_initialInstruction;
noOp IF_noOpModule(
	.initiaInstruction(IF_initialInstruction),
	.ID_NoOp(ID_noOp),
	.ID_PreNoOp(ID_preNoOp),

	.instr(IF_instr),
	.IF_NoOp(IF_noOp),
	.IF_PreNoOp(IF_preNoOp)
);

/****************************************************************************
****************************** IF/ID REGISTERS ******************************
****************************************************************************/

reg[31:0] ID_PCplusFour, ID_instr;
always @(posedge clk) begin
	if (reset) ID_noOp <= 1'b0;
	else ID_noOp <= IF_noOp;

	if (reset) ID_preNoOp <= 1'b0;
	else ID_preNoOp <= IF_preNoOp;

	if (reset) ID_PCplusFour <= 32'b0;
	else ID_PCplusFour <= IF_PCplusFour;

	if (reset) ID_instr <= `NOP;
	else ID_instr <= IF_instr;
end

/*******************************************************************************
****************************** INSTRUCTION DECODE ******************************
*******************************************************************************/

wire[4:0] ID_rs, ID_rt;
wire[5:0] ID_opcode, ID_funct;
assign ID_rs = ID_instr[25:21];
assign ID_rt = ID_instr[20:16];
assign ID_opcode = ID_instr[31:26];
assign ID_funct  = ID_instr[5:0];

wire[31:0] ID_Rrs, ID_Rrt, ID_forwardedRrt, ID_forwardedRrs;
reg[4:0] MEM_regAddr, WB_regAddr;
reg[31:0] MEM_regDat, WB_regDat;
wire WB_regWr, MEM_regWr;
forwarding ID_RrsForwarding(
	.targetReg(ID_rs),
	.targetData(ID_Rrs),
	.MEM_reg(MEM_regAddr),
	.MEM_data(MEM_regDat),
	.MEM_regWr(MEM_regWr),
	.WB_reg(WB_regAddr),
	.WB_data(WB_regDat),
	.WB_regWr(WB_regWr),
	.data(ID_forwardedRrs)
);

forwarding ID_RrtForwarding(
	.targetReg(ID_rt),
	.targetData(ID_Rrt),
	.MEM_reg(MEM_regAddr),
	.MEM_data(MEM_regDat),
	.MEM_regWr(MEM_regWr),
	.WB_reg(WB_regAddr),
	.WB_data(WB_regDat),
	.WB_regWr(WB_regWr),
	.data(ID_forwardedRrt)
);

wire[31:0] ID_initialBranchAddr, ID_branchAddr;
Adder ID_branchAddrAdder(
	.operandA(ID_PCplusFour),
	.operandB({{14{ID_instr[15]}}, ID_instr[15:0], 2'b0}),
	.result(ID_initialBranchAddr),
	.carryout(),
	.overflow()
);

branchTest ID_branchTest(
	.opcode(ID_opcode),
	.Da(ID_forwardedRrs),
	.Db(ID_forwardedRrt),
	.initialBranchAddress(ID_initialBranchAddr),
	.branchAddress(ID_branchAddr)
);

wire ID_isJR;
and ID_isJRAnd(ID_isJR, ~ID_opcode[5], ~ID_opcode[4], ~ID_opcode[3], ~ID_opcode[2], ~ID_opcode[1], ~ID_opcode[0], ID_funct[3], ~ID_funct[1]);
mux #(32) ID_branchOrJRMux(
	.input0(ID_branchAddr),
	.input1(ID_forwardedRrs),
	.out(ID_JRorBranchAddr),
	.sel(ID_isJR) //only high with a bne or beq
);

/****************************************************************************
****************************** ID/EX REGISTERS ******************************
****************************************************************************/

reg[31:0] EX_PCplusFour, EX_instr, EX_Rrs, EX_Rrt;
always @(posedge clk) begin
	if (reset) EX_PCplusFour <= 32'b0;
	else EX_PCplusFour <= ID_PCplusFour;
	
	if (reset) EX_instr <= `NOP;
	else EX_instr <= ID_instr;

	if (reset) EX_Rrs <= 32'b0;
	else EX_Rrs <= ID_Rrs;

	if (reset) EX_Rrt <= 32'b0;
	else EX_Rrt <= ID_Rrt;
end

/********************************************************************
****************************** EXECUTE ******************************
********************************************************************/

wire[4:0] EX_rs, EX_rt, EX_rd;
wire[31:0] EX_SEImm;
wire[5:0] EX_opcode, EX_funct;
assign EX_rs = EX_instr[25:21];
assign EX_rt = EX_instr[20:16];
assign EX_rd = EX_instr[15:11];
assign EX_SEImm = {{16{EX_instr[15]}},EX_instr[15:0]};
assign EX_opcode = EX_instr[31:26];
assign EX_funct  = EX_instr[5:0];

wire[31:0] EX_forwardedRrs, EX_forwardedRrt;
forwarding EX_rs_forwarding(
	.targetReg(EX_rs),
	.targetData(EX_Rrs),
	.MEM_reg(MEM_regAddr),
	.MEM_data(MEM_regDat),
	.MEM_regWr(MEM_regWr),
	.WB_reg(WB_regAddr),
	.WB_data(WB_regDat),
	.WB_regWr(WB_regWr),
	.data(EX_forwardedRrs)
);

forwarding EX_rt_forwarding(
	.targetReg(EX_rt),
	.targetData(EX_Rrt),
	.MEM_reg(MEM_regAddr),
	.MEM_data(MEM_regDat),
	.MEM_regWr(MEM_regWr),
	.WB_reg(WB_regAddr),
	.WB_data(WB_regDat),
	.WB_regWr(WB_regWr),
	.data(EX_forwardedRrt)
);

wire EX_RrtOrImmSel;
wire[31:0] EX_RrtOrImm;
or EX_selRrtOrImmOr(EX_RrtOrImmSel, EX_opcode[5], EX_opcode[3]);
mux #(32) EX_RrtOrImmMux(
	.input1(EX_SEImm),
	.input0(EX_forwardedRrt),
	.out(EX_RrtOrImm),
	.sel(EX_RrtOrImmSel) 
);

wire[31:0] EX_ALUres;
ALU EX_ALU(
	.operandA(EX_forwardedRrs),
	.operandB(EX_RrtOrImm),
	.opcode(EX_opcode),
	.funct(EX_funct),
	.res(EX_ALUres),
	.zero(),
	.overflow(),
	.carryout()
);

wire[31:0] EX_regDat;
wire EX_JAL;
and EX_ALUresOrPCPlusFourAnd(EX_JAL, ~EX_opcode[5], ~EX_opcode[3], EX_opcode[1], EX_opcode[0]);
mux #(32) EX_ALUresOrPCPlusFourMux(
	.input1(EX_PCplusFour),
	.input0(EX_ALUres),
	.out(EX_regDat),
	.sel(EX_JAL)
);

wire[4:0] EX_rdOrRt;
wire EX_Rtype;
nor EX_RtypeNor(EX_Rtype, EX_opcode[0], EX_opcode[1], EX_opcode[2], EX_opcode[3], EX_opcode[4], EX_opcode[5]);
mux #(5) EX_rdOrRtMux (
	.input1(EX_rd),
	.input0(EX_rt),
	.sel(EX_Rtype),
	.out(EX_rdOrRt)
);

wire[4:0] EX_regAddr;
mux #(5) EX_regAddrMux(
	.input1(5'd31),
	.input0(EX_rdOrRt),
	.sel(EX_JAL),
	.out(EX_regAddr)
);

/*****************************************************************************
****************************** EX/MEM REGISTERS ******************************
*****************************************************************************/

reg[31:0] MEM_instr, MEM_Rrt; //MEM_regDat and MEM_regAddr created earlier
always @(posedge clk) begin
	if (reset) MEM_instr <= `NOP;
	else MEM_instr <= EX_instr;

	if (reset) MEM_Rrt <= 32'b0;
	else MEM_Rrt <= EX_forwardedRrt;

	if (reset) MEM_regDat <= 32'b0;
	else MEM_regDat <= EX_regDat;

	if (reset) MEM_regAddr <= 5'b0;
	else MEM_regAddr <= EX_regAddr;
end 

/*******************************************************************
****************************** MEMORY ******************************
*******************************************************************/

wire[4:0] MEM_rt;
wire[5:0] MEM_opcode, MEM_funct;
wire MEM_memWr, MEM_LW;
assign MEM_rt = MEM_instr[20:16];
assign MEM_opcode = MEM_instr[31:26];
assign MEM_funct = MEM_instr[5:0];

and MEM_memWrAnd(MEM_memWr, MEM_opcode[5], MEM_opcode[3], MEM_opcode[1], MEM_opcode[0]);
and MEM_LWAnd(MEM_LW, MEM_opcode[5], ~MEM_opcode[3], MEM_opcode[1], MEM_opcode[0]);

wire[31:0] MEM_forwardedRrt; 
forwarding MEM_rt_forwarding(
	.targetReg(MEM_rt),
	.targetData(MEM_Rrt),
	.MEM_reg(MEM_regAddr),
	.MEM_data(MEM_regDat),
	.MEM_regWr(MEM_regWr),
	.WB_reg(WB_regAddr),
	.WB_data(WB_regDat),
	.WB_regWr(WB_regWr),
	.data(MEM_forwardedRrt)
);

wire[31:0] MEM_finalRegDat, MEM_dataOut;
mux #(32) MEM_regDataMux(
	.input0(MEM_regDat),
	.input1(MEM_dataOut),
	.sel(MEM_LW),
	.out(MEM_finalRegDat)
);


regWrLUT MEM_regWrLUT(
	.opcode(MEM_opcode),
	.funct(MEM_funct),
	.regwr(MEM_regWr)
);

/*****************************************************************************
****************************** MEM/WB REGISTERS ******************************
*****************************************************************************/

reg[31:0] WB_instr; //WB_regDat and WB_regAddr created earlier
always @(posedge clk) begin
	if (reset) WB_instr <= `NOP;
	else WB_instr <= MEM_instr;

	if (reset) WB_regDat <= 32'b0;
	else WB_regDat <= MEM_finalRegDat;

	if (reset) WB_regAddr <= 5'b0;
	else WB_regAddr <= MEM_regAddr;
end // always @(posedge clk)

/***********************************************************************
****************************** WRITE BACK ******************************
***********************************************************************/

wire[5:0] WB_opcode, WB_funct;
assign WB_opcode = WB_instr[31:26];
assign WB_funct  = WB_instr[5:0];

regWrLUT WB_regWrLUT(
	.opcode(WB_opcode),
	.funct(WB_funct),
	.regwr(WB_regWr)
);

/*********************************************************************************
****************************** UNIVERSAL COMPONENTS ******************************
*********************************************************************************/

regfile register(
	.ReadData1(ID_Rrs),
	.ReadData2(ID_Rrt),
	.ReadRegister1(ID_rs),
	.ReadRegister2(ID_rt),

	.WriteData(WB_regDat),
	.WriteRegister(WB_regAddr),
	.wEnable(WB_regWr),

	.Clk(clk)
);

memoryReg memory(
	.addressRead(IF_programCounter[13:2]),
	.dataOutRead(IF_initialInstruction),
	
	.dataOutRW(MEM_dataOut),
	.addressRW(MEM_regDat[13:2]),
	.writeEnableRW(MEM_memWr),
	.dataInRW(MEM_forwardedRrt),
	
	.addressWrite(12'b0), //Don't actually need the second write port
	.writeEnableWrite(1'b0),
	.dataInWrite(32'b0),

	.clk(clk)
);

endmodule // CPU