module AddSubModule (fromASBus, fleg, dataInBus, clk, RW, enable, matDecide, add1Sub0);
    output [255:0] fromASBus;
    output fleg;
    input [255:0] dataInBus;
	input RW, enable, clk, matDecide, add1Sub0;
    
    reg [255:0] fromASBus;
    reg fleg;
    
    reg [255:0] regOut;
    reg [15:0] in1_matMerc[3:0][3:0];
    reg [15:0] in2_matCol[3:0][3:0];
    reg [15:0] out_matTatami[3:0][3:0];
    reg [3:0] i;
    reg [3:0] j;
    reg [3:0] k;
    
    initial
    begin
        fleg = 0;
        for(i=0;i<4;i=i+1)
        begin
            for(j=0;j<4;j=j+1)
            begin
                out_matTatami[i][j] = 0;
            end
        end
    end
    
	// at negedge so that a whole clock cycle isn't wasted
	always @ (negedge clk)
	begin
		// when calculation is finished and flag needs to be brought down
		if (fleg == 1)
		begin
			fleg = 0;
		end
	end
	
    always @ (posedge clk)
    begin
	
		// when first matrix needs to be loaded into the module
		if(enable == 1 && RW == 1 && matDecide == 0)	
		begin
            for(i=0;i<4;i=i+1)
            begin
                for(j=0;j<4;j=j+1)
                begin
                    out_matTatami[i][j] = 0;
                end
            end
			for(i=0;i<4;i=i+1)
			begin
				for(j=0;j<4;j=j+1)
				begin
					in1_matMerc[i][j] = dataInBus[i*64+16*j+:16];
				end
			end
			fleg = 1;
		end
		
		// when the second matrix needs to be loaded into the module, and the calculation will then take place
		if (enable == 1 && RW == 1 && matDecide == 1)
		begin	
			for(i=0;i<4;i=i+1)
			begin
				for(j=0;j<4;j=j+1)
				begin
					in2_matCol[i][j] = dataInBus[i*64+16*j+:16];
				end
			end
            if(add1Sub0 == 1)
            begin
                for(i=0;i<4;i=i+1)
                begin
                    for(j=0;j<4;j=j+1)
                    begin
                        out_matTatami[i][j] = out_matTatami[i][j] + (in1_matMerc[i][j] + in2_matCol[i][j]);
                    end
                end
            end            
            if(add1Sub0 == 0)
            begin
                for(i=0;i<4;i=i+1)
                begin
                    for(j=0;j<4;j=j+1)
                    begin
                        out_matTatami[i][j] = out_matTatami[i][j] + (in1_matMerc[i][j] - in2_matCol[i][j]);
                    end
                end
            end
			for(i = 0;i<4;i = i +1)
			begin
				for(j=0;j<4;j = j +1)
				begin
					regOut[i*64+16*j+:16] = out_matTatami[i][j];
				end
			end
            fleg = 1;
		end
			
		// when data needs to be output
		if (enable == 1 && RW == 0)
		begin			
			fromASBus = regOut;
			fleg = 1;
		end
	end
    
endmodule