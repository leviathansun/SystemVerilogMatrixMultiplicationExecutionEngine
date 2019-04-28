module ExecEngine (dataOut, dataInBus, clk, multRW, tranRW, memRW, subRW, addRW, multFleg, tranFleg, memFleg, subFleg, addFleg);
output reg [255:0] dataOut;
output reg multRW, tranRW, memRW, subRW, addRW, multFleg, tranFleg, memFleg, subFleg, addFleg;

input [255:0] dataInBus;
input clk;

parameter SUM = 4'b0001;
parameter SUB = 4'b0010;
parameter MUL = 4'b0011;
parameter SCA = 4'b0100;
parameter TRA = 4'b0101;
parameter STAAAHP = 4'b0000;

reg [15:0] opOp;
reg [2:0] opCase;
reg [7:0] scalar;
reg regMem1, regMem2, sum, sub, mul, sca, tra, staaahp;
reg [1:0] regMemOut;
reg [2:0] addrOut;
reg [2:0] addr1;
reg [2:0] addr2;

reg opCode;

always @ (posedge clk)
begin

end

always @ opCode
begin
		sum = 0;
		sub = 0;
		mul = 0;
		sca = 0;
		scalar = 8'b00000000;
		tra = 0;
		staaahp = 0;
		opOp = opCode;
		opCase = opOp >> 28;
		opOp = opOp << 4;
		regMemOut = opOp >> 30;
		opOp = opOp << 2;
		addrOut = opOp >> 24;
		opOp = opOp << 8;
		case(opCase)
			SUM:	
				begin	// for sumation instruction 
				sum = 1;
				regMem1 = opOp >> 31;
				opOp = opOp << 1;
				addr1 = opOp >> 24;
				opOp = opOp << 8;
				regMem2 = opOp >> 31;
				opOp = opOp << 1;
				addr2 = opOp >> 24;
				// $display("sum code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
				end
			SUB:	
				begin	// for subtraction instruction
				sub = 1;
				regMem1 = opOp >> 31;
				opOp = opOp << 1;
				addr1 = opOp >> 24;
				opOp = opOp << 8;
				regMem2 = opOp >> 31;
				opOp = opOp << 1;
				addr2 = opOp >> 24;
				// $display("sub: code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
				end
			MUL:	
				begin	// for multiplication instruction 
				mul = 1;
				regMem1 = opOp >> 31;
				opOp = opOp << 1;
				addr1 = opOp >> 24;
				opOp = opOp << 8;
				regMem2 = opOp >> 31;
				opOp = opOp << 1;
				addr2 = opOp >> 24;
				// $display("mul: code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
				end
			SCA:	
				begin	// for scalar multiplication instruction, scalar is an 8 bit int, src addresses not used
				sca = 1;
				scalar = opOp >> 8;
				regMem1 = 0;
				regMem2 = 0;
				addr1 = 3'b000;
				addr2 = 3'b000;
				// $display("sca: code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
				end
			TRA:	
				begin	// for translation instruction 
				tra = 1;
				regMem1 = opOp >> 31;
				opOp = opOp << 1;
				addr1 = opOp >> 24;
				opOp = opOp << 8;
				regMem2 = opOp >> 31;
				opOp = opOp << 1;
				addr2 = opOp >> 24;
				// $display("tra: code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
				end
			STAAAHP:	
				begin	// for staaahp instruction. Ends Simulation.
				staaahp = 1;
				addr1 = 3'b000;
				addr2 = 3'b000;
				regMem1 = 0;
				regMem2 = 0;
				$display("Oh, hi Mark.");
				#4 $stop;
				end
			default: $display ("Error in opcodes"); 
		endcase
end
endmodule