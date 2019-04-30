module Op_Mem (opBus, opFleg, opCount, opRW, opEN, opWriteBus, clk);
output [31:0] opBus;
output reg opFleg;
input [3:0] opCount;
input clk;
input [31:0] opWriteBus;
input opRW, opEN;

reg [31:0] opBus;
reg [32:0] opMemArray[7:0];

initial
begin
    $readmemb("opMem.mem", opMemArray);
    opFleg = 0;
end

always @ (negedge clk)
begin
    if (opFleg == 1)
    begin
        opFleg = 0;
    end
end

// if read, output, if write, write to current wCount
always @ (posedge clk)
	begin
        if(opEN == 1)
        begin
            if (opRW == 1)
            begin
                opBus = opMemArray[opCount];
                
                opFleg = 1;
            end
            else if (opRW == 0)
            begin
                opMemArray[opCount] = opWriteBus;
                // $display("opMemArray[%bb]: %hh", wCount, opMemArray[wCount]);
                
                opFleg = 1;
            end
        end
    end
	

endmodule