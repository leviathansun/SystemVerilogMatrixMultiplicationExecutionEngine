module Mem (memBus, memAddr, memRW, memWrite, memDo);
output [255:0] memBus;
input [7:0] memAddr;
input [255:0] memWrite;
input memRW, memDo;

reg [255:0] memBus;
// memory itself
reg [255:0] memArray[7:0];

always @ (posedge memDo)
// if rw is 1, read from new address, if rw is 0, write to new address
begin
	if (memRW == 1)  
	begin
		memBus = memArray[memAddr];
	end
	else
	begin
        if (memRW == 0)
        begin
            memArray[memAddr] = memWrite;
			$display("memArray[%bb]: %hh", memAddr, memArray[memAddr]);
        end
    end
end
endmodule