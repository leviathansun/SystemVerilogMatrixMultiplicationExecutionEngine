module Reg_Mem (regBus, regFleg, regEN, regRW, regWrite, clk);
output [255:0] regBus;
output reg regFleg;
input regEN, clk;
input [255:0] regWrite;
input regRW;

reg [255:0] regBus;

// register itself
reg [255:0] regMem;

always @ (negedge clk)
begin
	if (regFleg == 1) 
	begin
		regFleg = 0;
	end
end

always @ (posedge clk)
// if rw is 1, read from new address, if rw is 0, write to new address
begin
    if(regEN == 1)
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
end
endmodule
