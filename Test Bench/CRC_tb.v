`timescale 1ns/1ps

module CRC_tb;


/*********************************************************
********************** Parameters ************************
*********************************************************/

localparam  Clock_Period  = 100;	// Clock Period = 100 ns 
localparam  CRC_Width     = 8;          // Register Width
localparam  testCases_num = 10;		// 10 Test Cases


/*********************************************************
********************** Variables *************************
*********************************************************/

integer OP;


/*********************************************************
*************** Module's Inputs & Outputs ****************
*********************************************************/

reg   CLK_tb, RST_tb;
reg   Data_tb; 
reg   Active_tb;
wire  CRC_tb, Valid_tb;


/*********************************************************
****************** Test Cases Memories *******************
*********************************************************/

reg [CRC_Width-1 : 0] Test_Data [0 : testCases_num-1];
reg [CRC_Width-1 : 0] Expec_Out [0 : testCases_num-1];



// DUT Instantiation
CRC DUT (
	.CLK    (CLK_tb),
	.RST    (RST_tb),
	.Active (Active_tb),
	.Data   (Data_tb),
	.Valid  (Valid_tb),
	.CRC    (CRC_tb)
);


// Clock Generator
initial
begin
	forever #(Clock_Period/2) CLK_tb = ~CLK_tb;
end


/*********************************************************
***************** Test Bench Main Code *******************
*********************************************************/

initial
begin

	// Saving Test
	$dumpfile ("CRC_Res.vcd");
	$dumpvars;

	// Loading Memories With Test Cases
	$readmemh ("DATA_h.txt", Test_Data, 0);
	$readmemh ("Expec_Out_h.txt", Expec_Out, 0);

	init ();	// Initialize The Module Inputs

	// Applying Test Cases
	for (OP = 0; OP < testCases_num; OP = OP+1)
	begin
		start_test (Test_Data[OP]);
		check_out  (Expec_Out[OP], OP);
	end

	$finish;

end




/*********************************************************
******************* Functions & Tasks ********************
*********************************************************/

/*
 * Description:
 * 1. Gives The Initial Values For Input Signals
*/

task init;

	begin

		CLK_tb    = 1'b0;
		RST_tb    = 1'b1;
		Active_tb = 1'b0;
		Data_tb   = 1'b0;	

	end

endtask


/*
 * Description:
 * 1. Reset The LFSR With The Constant Seed
*/

task reset;

	begin

		RST_tb    = 1'b0;
		#Clock_Period;
		RST_tb    = 1'b1;	

	end

endtask


/*
 * Description:
 * 1. Take The Input Data From The User
 * 2. Reset The LFSR
 * 3. Raise The Active Signal
 * 4. Start Generating The CRC Bits Depending On The Data Size By Shifting Data Bits
 * 5. Turn Off The Active Signal 
*/

task start_test;

	input [CRC_Width-1 : 0] Data_in;
	
	integer i;

	begin

		reset ();
		Active_tb = 1'b1;

		for (i = 0; i < CRC_Width; i = i+1)
		begin
			Data_tb = Data_in [i];
			#Clock_Period;
		end
		
		Active_tb = 1'b0;
			
	end

endtask


/*
 * Description:
 * 1. Take The Expected Ouput Data From The User
 * 2. Shift CRC Bits Serially On The Outpur Port
 * 3. Store The CRC Sequence Generated
 * 4. Compare CRC Sequence With The Expected Ouput
 * 5. Display If There Is A Matching Or Not 
*/

task check_out;

	input         [CRC_Width-1 : 0] Expected_Output;
	input integer                   OP;
	
	reg           [CRC_Width-1 : 0] CRC_Output;         
	
	integer i;

	begin
		$display ("Test Case %0d State: ", OP+1);
		#Clock_Period;

		for (i = 0; i < 8; i = i+1)
		begin
			CRC_Output [i] = CRC_tb;
			#Clock_Period;
		end
		
		if (CRC_Output == Expected_Output)
			$display ("Succeeded\n");
		else
			$display ("Failed\n");
			
	end

endtask

endmodule
