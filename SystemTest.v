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
wire [255:0] fromMultBus;
wire [255:0] fromASBus;
wire [255:0] fromTranBus;
wire [31:0] fromOpBus;
wire [7:0] memAddr;
wire [3:0] opCounter;
wire multEN, tranEN, addEN, memEN, regEN, opEN, add1sub0, matDecide;

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
multRW, tranRW, addRW, memRW, regRW, opRW, matDecide,
multEN, tranEN, addEN, memEN, regEN, opEN, add1sub0,
memAddr, opCounter, 

fromMemBus, fromRegBus, fromMultBus, fromASBus, fromTranBus,  fromOpBus,
multFleg, tranFleg, memFleg, addFleg, memFleg, regFleg, opFleg, clk, RESET);
//
Op_Mem OperationTheGame (fromOpBus, opFleg, opCounter, opRW, opEN, opWriteBus, clk);

Reg_Mem Reggie (fromRegBus, regFleg, regEN, regRW, toRegBus, clk);

Mem Remembral (fromMemBus, memFleg, memAddr, memRW, toMemBus, memEN, clk);

MatrixMultiplication timesMe (fromMultBus, multFleg, toModuleBus, clk, multRW, multEN, matDecide);

TranslationModule TransMog (fromTranBus, tranFleg, toModuleBus, clk, tranRW, tranEN, matDecide);

AddSubModule addSubMod (fromASBus, addFleg, toModuleBus, clk, addRW, addEN, matDecide, add1sub0);

initial
begin
    clk = 1'b0;
end

always
begin
    #1 clk = ~clk;
end

initial
begin    
    #11 RESET = 1; 
end

endmodule