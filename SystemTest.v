module System_Test;
reg clk;

always
begin
	if(clk == 0)
	clk = 1;
	else if (clk == 1)
	clk = 0;
end

endmodule