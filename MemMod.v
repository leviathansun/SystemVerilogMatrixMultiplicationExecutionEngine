module Mem (memBus, memFleg, memAddr, memRW, toMemBus, memEN, clk);
output [255:0] memBus;
output reg memFleg;
input [7:0] memAddr;
input [255:0] toMemBus;
input memRW, memEN, clk;

reg [255:0] memBus;
// memory itself
reg [255:0] memArray[7:0];

initial
begin
    memFleg = 0;
    $readmemh("mem.mem", memArray);
end

always @ (negedge clk)
begin
    if (memFleg == 1)
    begin
        memFleg = 0;
    end
end

always @ (posedge clk)
// if rw is 1, read from new address, if rw is 0, write to new address
begin
    if (memEN == 1)
	begin
        if (memRW == 1)  
        begin
            memBus = memArray[memAddr];
            memFleg = 1;
        end
        else
        begin
            if (memRW == 0)
            begin
                memArray[memAddr] = toMemBus;
                $display("memArray[%bb]: %hh", memAddr, memArray[memAddr]);
            end
        end
        memFleg = 1;
    end
end
endmodule