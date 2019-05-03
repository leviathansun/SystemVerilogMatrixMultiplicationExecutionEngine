module ExecEngine (toMemBus, toModuleBus, toRegBus, toOpBus,
multRW, tranRW, addRW, memRW, regRW, opRW, matDecide,
multEN, tranEN, addEN, memEN, regEN, opEN, add1sub0,
memAddr, opCounter, 
fromMemBus, fromRegBus, fromMultBus, fromASBus, fromTranBus, fromOpBus,
multFleg, tranFleg, memFleg, addFleg, memFleg, regFleg, opFleg, clk, RESET);

// system wide connections
output reg [255:0] toModuleBus;
output reg matDecide;
input [255:0] fromMultBus;
input clk;
input RESET;
reg [255:0] matrix1;
reg [255:0] matrix2;
reg [255:0] matrixOUT;
reg [16:0] displayMatrix[3:0][3:0];

// stop variables
parameter STAAAHP = 4'b0000;

// multiply/scale module variables, inmput wires, and output registers
parameter SCA = 4'b0100;
parameter MUL = 4'b0011;
input [255:0] fromASBus;
output reg multRW, multEN;
input multFleg;
reg [255:0] matrixScalar;
integer scali;
integer j;

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

initial // set enables to zero at initial
begin
    opRead = 0;
    opEN = 0;
    memEN = 0;
    regEN = 0;
    memEN = 0;
    tranEN = 0;
    multEN = 0;
    
    for(scali=0;scali<256;scali=scali+1)
    begin
        matrixScalar[scali] = 0;
    end
end

always @ (posedge clk) // reset buses when new operation is needed
begin
    if (runExecutions == 1)
    begin
        if (opRead == 1)
        begin
            opRW = 1;
            opEN = 1;
            toMemBus = 255'b0;
            toModuleBus = 255'b0;
            toRegBus = 255'b0;
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
    opEN = 0;
    memEN = 0;
    regEN = 0;
    memEN = 0;
    tranEN = 0;
    multEN = 0;
    multEN = 0;
    tranEN = 0;
    addEN = 0;
    memEN = 0;
    regEN = 0;
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
    case(opCase) // basic explination of module control, 1. put info and control on busses 2. EN = 1 3. on flag, EN = 0 4. back to one for next step 5. if no next step, get new opcode and reset busses
        SUM:	
            begin	// for sumation instruction 
            regMem1 = opOp >> 31;
            opOp = opOp << 1;
            addr1 = opOp >> 24;
            opOp = opOp << 8;
            regMem2 = opOp >> 31;
            opOp = opOp << 1;
            addr2 = opOp >> 24;
            matDecide = 0;
            addRW = 1;
            memToEgg(regMem1, addr1); // calls task to retrieve specified matrix from memory module
            toModuleBus = matrix1;
            addEN = 1;
            @ (posedge addFleg) addEN = 0;
            matDecide = 1;
            add1sub0 = 1;
            memToEgg(regMem2, addr2); // calls task to retrieve specified matrix from memory module
            toModuleBus = matrix2;
            addEN= 1;
            @ (posedge addFleg) addEN = 0;
            addRW = 0;
            addEN = 1;
            @ (posedge addFleg) 
            begin
                matrixOUT = fromASBus; 
                addEN = 0;
                addRW = 0;
            end
			addEN = 1;
            toRegBus = matrixOUT;
            if(regMemOut == 2'b11) // if goes to register and memory
            begin
                regRW = 0;
                memRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end
            if(regMemOut == 2'b10) // if goes to register and memory
            begin
                regRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
            end
            if(regMemOut == 2'b01) // if goes to register and memory
            begin
                memRW = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end
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
            matDecide = 0;
            addRW = 1;
            memToEgg(regMem1, addr1); // calls task to retrieve specified matrix from memory module
            toModuleBus = matrix1;
            addEN = 1;
            @ (posedge addFleg) addEN = 0;
            matDecide = 1;
            add1sub0 = 0;
            memToEgg(regMem2, addr2); // calls task to retrieve specified matrix from memory module
            toModuleBus = matrix2;
            addEN= 1;
            @ (posedge addFleg) addEN = 0;
            addRW = 0;
            addEN = 1;
            @ (posedge addFleg) 
            begin
                matrixOUT = fromASBus; 
                addEN = 0;
                addRW = 0;
            end
			addEN = 1;
            toRegBus = matrixOUT;
            if(regMemOut == 2'b11) // if goes to register and memory
            begin
                regRW = 0;
                memRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end
            if(regMemOut == 2'b10) // if goes to register and memory
            begin
                regRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
            end
            if(regMemOut == 2'b01) // if goes to register and memory
            begin
                memRW = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end

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
            memToEgg(regMem1, addr1); // calls task to retrieve specified matrix from memory module
            toModuleBus = matrix1;
            multEN = 1;
            @ (posedge multFleg) multEN = 0;
            matDecide = 1;
            memToEgg(regMem2, addr2); // calls task to retrieve specified matrix from memory module
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
            toRegBus = matrixOUT;
            if(regMemOut == 2'b11) // if goes to register and memory
            begin
                regRW = 0;
                memRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end
            if(regMemOut == 2'b10) // if goes to register and memory
            begin
                regRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
            end
            if(regMemOut == 2'b01) // if goes to register and memory
            begin
                memRW = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end
			

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
            matDecide = 0;
            multRW = 1;
            memToEgg(regMem1, addr1); // calls task to retrieve specified matrix from memory module
            toModuleBus = matrix1;
            multEN = 1;
            @ (posedge multFleg) multEN = 0;
            matDecide = 1;
            scalyMatrix(addr2);
            toModuleBus = matrixScalar;
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
            toRegBus = matrixOUT;
            if(regMemOut == 2'b11) // if goes to register and memory
            begin
                regRW = 0;
                memRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) multEN = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) multEN = 0;
            end
            if(regMemOut == 2'b10) // if goes to register and memory
            begin
                regRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
            end
            if(regMemOut == 2'b01) // if goes to register and memory
            begin
                memRW = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end
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
            matDecide = 0;
            tranRW = 1;
            memToEgg(regMem1, addr1); // calls task to retrieve specified matrix from memory module
            toModuleBus = matrix1;
            tranEN = 1;
            @ (posedge tranFleg) tranEN = 0;
            tranRW = 0;
            tranEN = 1;
            @ (posedge tranFleg) 
            begin
                matrixOUT = fromTranBus; 
                tranEN = 0;
                tranRW = 0;
            end
			tranEN = 1;
            toModuleBus = matrixOUT;
            if(regMemOut == 2'b11) // if goes to register and memory
            begin
                regRW = 0;
                memRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end
            if(regMemOut == 2'b10) // if goes to register and memory
            begin
                regRW = 0;
                toRegBus = matrixOUT;
                regEN = 1;
                @ (posedge regFleg) regEN = 0;
            end
            if(regMemOut == 2'b01) // if goes to register and memory
            begin
                memRW = 0;
                memAddr = addrOut;
                toMemBus = matrixOUT;
                memEN = 1;
                @ (posedge memFleg) memEN = 0;
            end
            end
        STAAAHP:	
            begin	// for staaahp instruction. Ends Simulation.
            addr1 = 3'b000;
            addr2 = 3'b000;
            regMem1 = 0;
            regMem2 = 0;
            eggToDisplay(toMemBus);
            staaaph();
            $display("Oh, hi Mark.");
            end
        default: $display ("Error in opcodes"); 
    endcase
    opCounter = opCounter +1;
    opRead = 1;
end
    
task memToEgg; // take data from memory to execution unit
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
            if(matDecide == 0) matrix1 = fromRegBus;
            if(matDecide == 1) matrix2 = fromRegBus;
        end
    end
endtask
    
task eggToDisplay; // display a given matrix
    input [255:0] matrixD;
    integer i;
    begin
       for(i = 0;i<4;i = i +1)
        begin
            for(j=0;j<4;j = j +1)
            begin
                displayMatrix[i][j] = matrixD[i*64+16*j+:16];
            end
        end
        $displayh(displayMatrix);
    end 
endtask
        
task scalyMatrix; //create identity matrix for scalar
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