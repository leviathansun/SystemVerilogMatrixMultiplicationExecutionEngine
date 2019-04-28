module Op_Mem (opBus, wCount, rCount, opWrite, opRead);
output [31:0] opBus;
input [2:0] wCount;
input [2:0] rCount;
input opRead;
input [31:0] opWrite;

reg [31:0] opBus;
reg [31:0] opMemArray[7:0];


// if read, output, if write, write to current wCount
always @ (posedge opRead)
	begin
		opBus = opMemArray[rCount];
	end
always @ opWrite
	begin
		opMemArray[wCount] = opWrite;
		$display("opMemArray[%bb]: %hh", wCount, opMemArray[wCount]);
    end
	

endmodule