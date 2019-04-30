/*
    Matrix multiplication module multiplies two matrices and outputs the result once it recieves two 
    separate matices. Variable mat1LowMat2High keeps track of how many matrices have been recieved since last output
*/

module MatrixMultiplication (dataOut, fleg, dataInBus, clk, RW, enable);
    output [255:0] dataOut;
    output fleg;
    input [255:0] dataInBus;
	input RW, enable, clk;
    
    reg [255:0] dataOut;
    reg fleg;
    
    reg [255:0] regOut;
    reg [15:0] in1_matMerc[3:0][3:0];
    reg [15:0] in2_matCol[3:0][3:0];
    reg [15:0] out_matTatami[3:0][3:0];
    reg [3:0] i;
    reg [3:0] j;
    reg [3:0] k;
    reg mat1LowMat2High;
    
    initial
    begin
        mat1LowMat2High = 0;
        fleg = 0;
        for(i=0;i<4;i=i+1)
        begin
            for(j=0;j<4;j=j+1)
            begin
                out_matTatami[i][j] = 0;
            end
        end
        // $display("%p", out_matTatami);
    end
    
	// at negedge so that a whole clock cycle isn't wasted
	always @ (negedge clk)
	begin
		// when calculation is finished and flag needs to be brought up
		if(enable == 1 && RW == 1 && mat1LowMat2High == 1)	
		begin
			mat1LowMat2High = 0;
		end
		
		if (fleg == 1)
		begin
			fleg = 0;
		end
	end
	
    always @ (posedge clk)
    begin
	
		// when first matrix needs to be loaded into the module
		if(enable == 1 && RW == 1 && mat1LowMat2High == 0 && fleg == 0)	
		begin
			for(i=0;i<4;i=i+1)
			begin
				for(j=0;j<4;j=j+1)
				begin
					in1_matMerc[i][j] = dataInBus[i*64+16*j+:16];
				end
			end
			mat1LowMat2High = 1;
			fleg = 1;
		end
		
		// when the second matrix needs to be loaded into the module, and the calculation will then take place
		if (enable == 1 && RW == 1 && mat1LowMat2High == 1 && fleg == 1)
		begin	
			for(i=0;i<4;i=i+1)
			begin
				for(j=0;j<4;j=j+1)
				begin
					in2_matCol[i][j] = dataInBus[i*64+16*j+:16];
				end
			end
			for(i=0;i<4;i=i+1)
			begin
				for(j=0;j<4;j=j+1)
				begin
					for(k=0;k<4;k=k+1)
					begin
						out_matTatami[i][j] = out_matTatami[i][j] + (in1_matMerc[i][k]*in2_matCol[k][j]);
					end
				end
			end
			$display("%p", out_matTatami);
			$displayh("%p", out_matTatami);
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
		if (enable == 1 && RW == 0 && mat1LowMat2High == 0 && fleg == 1)
		begin			
			dataOut = regOut;
			fleg = 1;
		end
	end
    
endmodule
