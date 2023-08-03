module CRC (
input wire   CLK, RST,
input wire   Data,
input wire   Active,
output reg   Valid, CRC
);

/*********************************************************
*********************** Parameters ***********************
*********************************************************/

localparam [3:0] outputCounts = 4'd08;
localparam [7:0] Seed         = 8'hD8;
localparam [7:0] Taps         = 8'b01000100;     // Taps Defines The Xor Locations 



/*********************************************************
*********************** Variables ***********************
*********************************************************/

integer i;


/*********************************************************
**************** Design Internal Signals *****************
*********************************************************/

reg [7:0] LFSR;		// Internal Linear Feedback Shift Register
reg [2:0] Counter;	// Internal Counter 
reg       Done;		// Counter Done Signal
wire      FB;		// Internal Feedback Signal
  



// Internal Feedback Signal Logic
assign FB = Data ^ LFSR[0];


/* Counter Block:
*   1. Calculating The Number Of Edges During Which The Output Is Valid
*   2. After Shifting All The Output Bits Out, It Sends A Signal To Stop Shifting Operation
*/

always @ (posedge CLK, negedge RST)
begin

	if (!RST)
	begin
		Counter <= 4'b0;	
		Done    <= 1'b1;
	end

	else if (!Active && !Done)
	begin
		if (Counter != outputCounts-1)
		begin
			Counter <= Counter + 1;
			Done    <= 1'b0;
		end

		else
		begin
			Counter <= Counter + 1;
			Done    <= 1'b1;
		end
	end

	else if (Active)
	begin
		Done = 1'b0;
	end

end 



// Cyclic Redundancy Check Implementation

always @ (posedge CLK, negedge RST)
begin

	if (!RST)
	begin
		LFSR  <= Seed;
		CRC   <= 1'b0;
		Valid <= 1'b0;
	end

	else if (Active)
	begin
		LFSR[7] <= LFSR[0] ^ Data;

		for(i = 0; i < 7; i = i+1)
		begin
			if (Taps[i])
				LFSR[i] <= LFSR[i+1] ^ FB;
			else
				LFSR[i] <= LFSR[i+1];
		end
	end

	else if (!Done)
	begin
		Valid <= 1'b1;
		{LFSR[6:0], CRC} <= LFSR;
	end

	else
	begin
		Valid <= 1'b0;
	end

end

endmodule
