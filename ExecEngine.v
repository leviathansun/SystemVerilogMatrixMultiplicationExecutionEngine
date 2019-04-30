module ExecEngine (toMemBus, toModuleBus, toRegBus, toOpBus,
multRW, tranRW, addRW, memRW, regRW, opRW, matDecide,
multEN, tranEN, addEN, memEN, regEN, opEN, add1sub0,
memAddr, opCounter, 
fromMemBus, fromRegBus, fromMultBus,  fromASBus, fromTranBus, fromOpBus,
multFleg, tranFleg, memFleg, subFleg, addFleg, memFleg, regFleg, opFleg, clk, RESET);

// system wide connections
output reg [255:0] toModuleBus;
output reg matDecide;
input [255:0] fromMultBus;
input clk;
input RESET;
reg [255:0] matrix1;
reg [255:0] matrix2;
reg [255:0] matrixOUT;

// stop variables
parameter STAAAHP = 4'b0000;

// multiply/scale module variables, inmput wires, and output registers
parameter SCA = 4'b0100;
parameter MUL = 4'b0011;
input [255:0] fromASBus;
output reg multRW, multEN;
input multFleg;
reg [255:0] matrixScalar;

// transpose module variables, wires, and registers
parameter TRA = 4'b0101;
input [255:0] fromTranBus;
output reg tranRW, tranEN;
input tranFleg;

// memory and reg module variables, wires, and registers
output reg [7:0] memAddr;
output reg [255:0] toMemBus;
output reg [255:0] toRegBus;
output reg memRW, memEN, regRW, regEN;
input [255:0] fromMemBus; 
input [255:0] fromRegBus;
input memFleg, regFleg;

// add/subtract module variables, wires, and registers
parameter SUM = 4'b0001;
parameter SUB = 4'b0010;
output reg add1sub0, addRW, addEN;
input addFleg;
input subFleg;

// opCode decode variables, input wires, and output registers
output reg [3:0] opCounter;
output reg opRW, opEN;
output reg [31:0] toOpBus;
input [31:0] fromOpBus;
input opFleg;
reg [31:0] opOp;
reg [3:0] opCase;
reg [7:0] scalar;
reg regMem1, regMem2, sum, sub, mul, sca, tra, staaahp;
reg [1:0] regMemOut;
reg [7:0] addrOut;
reg [7:0] addr1;
reg [7:0] addr2;
reg opWrite, mapDecide;
reg runExecutions;

reg opRead; // runs entire script, grabbing next op


// Op_Mem OperationTheGame (opBus, opFleg, opCounter, opRW, toOpBus, clk);
// Reg_Mem Reggie (regBus, regFleg, regDo, regRW, regWrite, clk);
// Mem Remembral (memBus, memFleg, memAddr, memRW, memWrite, memDo, clk);
// MatrixMultiplication timesMe (dataOut, fleg, dataInBus, clk, RW, enable);

initial
begin
    opRead = 0;
    opEN = 0;
    memEN = 0;
    regEN = 0;
    memEN = 0;
    tranEN = 0;
    multEN = 0;
end

always @ (posedge clk)
begin
    if (runExecutions == 1)
    begin
        if (opRead == 1)
        begin
            opRW = 1;
            opEN = 1;
        end
    end 
end

always @ (posedge RESET)
begin
    // toOpBus = fromOpBus;
    // opRW = 1;
    opCounter = 4'b0000;
    opRead = 1;
    runExecutions = 1;
end

always @ fromOpBus
begin
    opRead = 0;
    sum = 0;
    sub = 0;
    mul = 0;
    sca = 0;
    scalar = 8'b00000000;
    tra = 0;
    staaahp = 0;
    opOp = fromOpBus;
    opCase = opOp >> 28;
    opOp = opOp << 4;
    regMemOut = opOp >> 30;
    opOp = opOp << 2;
    addrOut = opOp >> 24;
    opOp = opOp << 8;
    case(opCase)
        SUM:	
            begin	// for sumation instruction 
            regMem1 = opOp >> 31;
            opOp = opOp << 1;
            addr1 = opOp >> 24;
            opOp = opOp << 8;
            regMem2 = opOp >> 31;
            opOp = opOp << 1;
            addr2 = opOp >> 24;
            memToEgg(regMem1, addr1);

            // $display("sum code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
            end
        SUB:	
            begin	// for subtraction instruction
            regMem1 = opOp >> 31;
            opOp = opOp << 1;
            addr1 = opOp >> 24;
            opOp = opOp << 8;
            regMem2 = opOp >> 31;
            opOp = opOp << 1;
            addr2 = opOp >> 24;
            memToEgg(regMem1, addr1);

            // $display("sub: code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
            end
        MUL:	
            begin	// for multiplication instruction 
            regMem1 = opOp >> 31;
            opOp = opOp << 1;
            addr1 = opOp >> 24;
            opOp = opOp << 8;
            regMem2 = opOp >> 31;
            opOp = opOp << 1;
            addr2 = opOp >> 24;
            matDecide = 0;
            multRW = 1;
            memToEgg(regMem1, addr1);
            toModuleBus = matrix1;
            multEN = 1;
            @ (posedge multFleg) multEN = 0;
            matDecide = 1;
            memToEgg(regMem2, addr2);
            toModuleBus = matrix2;
            multEN= 1;
            @ (posedge multFleg) multEN = 0;
            multRW = 0;
            multEN = 1;
            @ (posedge multFleg) 
            begin
                matrixOUT = fromMultBus; 
                multEN = 0;
                multRW = 0;
            end
			multEN = 1;
			

            // $display("mul: code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
            end
        SCA:	
            begin	// for scalar multiplication instruction, scalar is an 8 bit int, src addresses not used
            regMem1 = opOp >> 31;
            opOp = opOp << 1;
            addr1 = opOp >> 24;
            opOp = opOp << 8;
            regMem2 = opOp >> 31;
            opOp = opOp << 1;
            addr2 = opOp >> 24;
            scalyMatrix(addr2);
            memToEgg(regMem1, addr1);
           // $display("sca: code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
            end
        TRA:	
            begin	// for translation instruction 
            regMem1 = opOp >> 31;
            opOp = opOp << 1;
            addr1 = opOp >> 24;
            opOp = opOp << 8;
            regMem2 = opOp >> 31;
            opOp = opOp << 1;
            addr2 = opOp >> 24;
            memToEgg(regMem1, addr1);

            // $display("tra: code: %b reg?: %b out: %b reg?: %b addr1: %b reg?: %b addr2: %b",opCase,regMemOut,addrOut,regMem1,addr1,regMem2,addr2);
            end
        STAAAHP:	
            begin	// for staaahp instruction. Ends Simulation.
            addr1 = 3'b000;
            addr2 = 3'b000;
            regMem1 = 0;
            regMem2 = 0;
            staaaph();
            modToEgg();
            eggToMem();
            eggToDisplay();
            staaaph();
            $display("Oh, hi Mark.");
            // #4 $stop;
            end
        default: $display ("Error in opcodes"); 
    endcase
end
    
task memToEgg;
    input regMem;
    input [7:0] addr;
    begin
        if(regMem == 0)
        begin
            memAddr = addr;
            memRW = 1;
            memEN = 1;
            @ (posedge memFleg) memEN = 0;
            if(matDecide == 0) matrix1 = fromMemBus;
            if(matDecide == 1) matrix2 = fromMemBus;
        end
        else if (regMem == 1)
        begin
            regRW = 1;
            regEN = 1;
            @ (posedge regFleg) regEN = 0;
            if(matDecide == 0) matrix1 = fromMemBus;
            if(matDecide == 1) matrix2 = fromMemBus;
        end
    end
endtask

task modToEgg;
    begin
    
    end    
endtask

task eggToMem;
    begin
       
       opCounter = opCounter + 1;
       opRead = 1;
    end       
endtask
    
task eggToDisplay;
    begin
       // for(i = 0;i<4;i = i +1)
        // begin
            // for(j=0;j<4;j = j +1)
            // begin
                // temp_matrix[i][j] = matrix[i*64+16*j+:16];
            // end
        // end
    end 
endtask
        
task scalyMatrix;
    input [7:0] scalar;
    integer i;
    begin
        matrixScalar [255:240] = scalar;
        for(i = 0;i<15;i = i +1)
            begin
                if (i%5==0)
                    matrixScalar[i*16+:16] = scalar;
            end
    end
endtask

task staaaph;
    begin
    runExecutions = 0;
    end    
endtask

endmodule

//dday of presentation things. One module that does them all is a single data in and out for the system


// final notes
// 1. define the logic gates for this diagram
// 2. reduce it
// 3. top down design 32bit something
// 4. melee and moore machines
// 5. test benches
// 6. combinational logic
// 7. state machine for _, it's a controller and controller is defined for you
// 8. write psuedocode for implementing a things
// 9. write something in verilog code
// 10. 