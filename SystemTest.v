module System_Test;
// registers into execution engine
reg clk;
reg RESET;

// connections inside system
wire  [255:0] toMemBus;
wire [255:0] toModuleBus;
wire [255:0] toRegBus;
wire [31:0] opWriteBus;
wire multRW, tranRW, memRW, subRW, addRW, multFleg, tranFleg, memFleg, subFleg, addFleg;
wire [255:0] fromMemBus;
wire [255:0] fromRegBus;
wire [255:0] fromModuleBus;
wire [31:0] fromOpBus;
wire [7:0] memAddr;
wire [3:0] opCounter;
wire [255:0] memWrite;
wire multEN, tranEN, addEN, memEN, regEN, opEN, add1sub0;

// test internal registers
reg [16:0] matrix1[3:0][3:0];
reg [16:0] matrix2[3:0][3:0];
reg [255:0] matToMem1;
reg [255:0] matToMem2;
reg [31:0] opcode;
integer i;
integer j;
//
ExecEngine exeggutor (toMemBus, toModuleBus, toRegBus, opWriteBus,
multRW, tranRW, addRW, memRW, regRW, opRW,
multEN, tranEN, addEN, memEN, regEN, opEN, add1sub0,
memAddr, opCounter, 

fromMemBus, fromRegBus, fromModuleBus,  fromOpBus,
multFleg, tranFleg, memFleg, subFleg, addFleg, memFleg, regFleg, opFleg, clk, RESET);
//
Op_Mem OperationTheGame (fromOpBus, opFleg, opCounter, opRW, opEN, opWriteBus, clk);

Reg_Mem Reggie (fromRegBus, regFleg, regEN, regRW, toRegBus, clk);

Mem Remembral (fromMemBus, memFleg, memAddr, memRW, memWrite, memEN, clk);

MatrixMultiplication timesMe (fromModuleBus, multFleg, toModuleBus, clk, multRW, multEN);

initial
begin
    clk = 1'b0;
end

always
begin
    #10 clk = ~clk;
end

initial
begin    
    #11 RESET = 1;
    
end

endmodule