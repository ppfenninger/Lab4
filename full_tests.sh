iverilog -o adder adder.t.v
iverilog -o alu alu.t.v
iverilog -o branchTest branchTest.t.v
iverilog -o CPU cpu.t.v
iverilog -o forwarding forwarding.t.v
iverilog -o jumpTest jumpTest.t.v
iverilog -o memReg memReg.t.v
iverilog -o mux mux.t.v
iverilog -o noOp no-op.t.v
iverilog -o regfile regfile.t.v
iverilog -o regWrLUT regWrLUT.t.v
iverilog -o signExtender signExtender.t.v

./adder
./alu
./branchTest
./forwarding
./jumpTest
./memReg
./mux
./noOp
./regfile
./regWrLUT
./signExtender
./CPU +mem_text_fn=myprog.text +dump_fn=divide.vcd

rm adder
rm alu
rm branchTest
rm forwarding
rm jumpTest
rm memReg
rm mux
rm noOp
rm regfile
rm regWrLUT
rm signExtender
rm CPU
