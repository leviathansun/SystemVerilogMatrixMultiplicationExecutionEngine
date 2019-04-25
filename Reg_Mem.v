module Reg_Mem (regBus, regDo, regRW, regWrite);
output [255:0] regBus;
input regDo;
input [255:0] regWrite;
input regRW;

reg [255:0] regBus;
// register itself
reg [255:0] regMem;

always @ (posedge regDo)
// if rw is 1, read from new address, if rw is 0, write to new address
begin
	if (regRW == 1) 
	begin
		regBus = regMem;
	end
	else
	begin
        if (regRW == 0)
        begin
            regMem = regWrite;
			$display("regMem = %hh", regMem);
        end
    end
end
endmodule
