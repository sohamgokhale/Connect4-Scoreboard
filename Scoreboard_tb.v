/*
 * Scoreboard Test Bench
 * ---------------------------
 *	By: Soham Gokhale
 *	For: University of Leeds - ELEC5566M-Mini-Project-Group-6
 * Date: 04 Apr 2023
 * 
 *	Description
 * -----------
 *	Test bench for Scoreboard module.
 *
 */
 
  //Timescale declaration
 `timescale 1 ns/100 ps
 
 module Scoreboard_tb;
 
 localparam ROWS = 4;
 localparam COLS = 4;
 localparam CONN = 3;
 
 reg						clock;			// Input Clock Signal
 reg 						reset;			//	Global reset.
 reg 						grid_full;
 reg [2*ROWS*COLS:0] game_status;	//	Status of all game values
 
 wire [1:0] winner;
 wire [7:0] p1_score;
 wire [7:0] p2_score;
 wire [7:0] draw_score;
 
 Scoreboard scoreboard_dut(
 
	.clock			(clock		),	// Input Clock Signal
	.reset			(reset		),	//	Global reset. Resets all scores
	.grid_full		(grid_full	),
	.game_status	(game_status),	//	Status of all game values
	
	.winner			(winner		),	// Round winner
	.p1_score		(p1_score	),	//	Rounds won by Player 1
	.p2_score		(p2_score	),	// Rounds won by Player 2
	.draw_score		(draw_score	)	// Rounds ended in a draw
 );
 
 localparam NUM_CYCLES = 1000; 			//Simulate this many clock cycles. Max. 1 billion
 localparam CLOCK_FREQ = 50000000;	//Clock frequency (in Hz)
 localparam RST_CYCLES = 2;			//Number of cycles of reset at beginning.
 
 integer i,j;
 reg [2*ROWS*COLS:0] p1;
 reg [2*ROWS*COLS:0] p2;
 
 initial begin
	game_status = {(2*ROWS*COLS){1'b0}};
	p1 = {(2*ROWS*COLS){1'b0}};
	p2 = {(2*ROWS*COLS){1'b0}};
	grid_full = 1'b0;
	
	$display("%d ns\tSimulation Started\n",$time);	//Print Simulation Start time to console
	
	$display("Testing Reset Condition");
	// Test Reset Condition
	clock = 1'b0;
	reset = 1'b1;
	repeat(5) @(posedge clock);
	reset = 1'b0;
	repeat(5) @(posedge clock);
	
	$display("Testing Horizontal Connect\n");
	// Check horizontal connect for both Player 1 and 2
	for (i = 0; i < ROWS; i = i + 1) begin
		for (j = 0; j <= COLS - CONN; j = j + 1) begin
			$write("Row [%d] Column [%d] Player 1 : ",$itor(i),$itor(j));
			game_status = {(CONN){2'b01}} << ((2*j)+(2*COLS*i));
			repeat(5) @(posedge clock);
			if(winner == 2'b01) begin 
				$display("Success!");
			end else begin
				$display("Failure!: Winner =%d",winner);
				$stop;
			end
			game_status = 32'd0;
			repeat(2) @(posedge clock);
			
			$write("Row [%d] Column [%d] Player 2 : ",$itor(i),$itor(j));
			game_status = {(CONN){2'b10}} << ((2*j)+(2*COLS*i));
			repeat(5) @(posedge clock);
			if(winner == 2'b10) begin 
				$display("Success!");
			end else begin
				$display("Failure!: Winner =%d",winner);
				$stop;
			end
			game_status = 32'd0;
			repeat(2) @(posedge clock);
		end
	end
	
	
	// Generate Input to test vertical connect for both players
	for(i = 0; i<CONN; i = i + 1) begin
		p1 = p1 | (2'b01) << (2*COLS*i);
		p2 = p2 | (2'b10) << (2*COLS*i);
	end
	$display("P1 string for vertical : %x",p1);
	$display("P2 string for vertical : %x",p2);
	
	
	$display("Testing Vertical Connect");
	// Check horizontal connect for both Player 1 and 2
	for (i = 0; i <= ROWS - CONN; i = i + 1) begin
		for (j = 0; j < COLS; j = j + 1) begin
			$write("Row [%d] Column [%d] Player 1 : ",$itor(i),$itor(j));
			game_status = p1 << ((2*j)+(2*COLS*i));
			repeat(5) @(posedge clock);
			if(winner == 2'b01) begin 
				$display("Success!");
			end else begin
				$display("Failure!: Winner =%d",winner);
				$stop;
			end
			game_status = 32'd0;
			repeat(2) @(posedge clock);
			
			$write("Row [%d] Column [%d] Player 2 : ",$itor(i),$itor(j));
			game_status = p2 << ((2*j)+(2*COLS*i));
			repeat(5) @(posedge clock);
			if(winner == 2'b10) begin 
				$display("Success!");
			end else begin
				$display("Failure!: Winner =%d",winner);
				$stop;
			end
			game_status = 32'd0;
			repeat(2) @(posedge clock);
		end
	end
	
	p1 = 32'h00100401;
	p2 = 32'h00200802;
	
	$display("Testing Upward Diagonal Connect");
	// Check horizontal connect for both Player 1 and 2
	for (i = 0; i <= ROWS - CONN; i = i + 1) begin
		for (j = 0; j <= COLS - CONN; j = j + 1) begin
			$write("Row [%d] Column [%d] Player 1 : ",$itor(i),$itor(j));
			game_status = p1 << ((2*j)+(2*COLS*i));
			repeat(5) @(posedge clock);
			if(winner == 2'b01) begin 
				$display("Success!");
			end else begin
				$display("Failure!: Winner =%d",winner);
				$stop;
			end
			game_status = 32'd0;
			repeat(2) @(posedge clock);
			
			$write("Row [%d] Column [%d] Player 2 : ",$itor(i),$itor(j));
			game_status = p2 << ((2*j)+(2*COLS*i));
			repeat(5) @(posedge clock);
			if(winner == 2'b10) begin 
				$display("Success!");
			end else begin
				$display("Failure!: Winner =%d",winner);
				$stop;
			end
			game_status = 32'd0;
			repeat(2) @(posedge clock);
		end
	end
	
	p1 = 32'h00010410;
	p2 = 32'h00020820;
	
	$display("Testing Downward Diagonal Connect");
	// Check horizontal connect for both Player 1 and 2
	for (i = 0; i <= ROWS - CONN; i = i + 1) begin
		for (j = 0; j <= COLS - CONN; j = j + 1) begin
			$write("Row [%d] Column [%d] Player 1 : ",$itor(i),$itor(j));
			game_status = p1 << ((2*j)+(2*COLS*i));
			repeat(5) @(posedge clock);
			if(winner == 2'b01) begin 
				$display("Success!");
			end else begin
				$display("Failure!: Winner =%d",winner);
				$stop;
			end
			game_status = 32'd0;
			repeat(2) @(posedge clock);
			
			$write("Row [%d] Column [%d] Player 2 : ",$itor(i),$itor(j));
			game_status = p2 << ((2*j)+(2*COLS*i));
			repeat(5) @(posedge clock);
			if(winner == 2'b10) begin 
				$display("Success!");
			end else begin
				$display("Failure!: Winner =%d",winner);
				$stop;
			end
			game_status = 32'd0;
			repeat(2) @(posedge clock);
		end
	end
	
	// Check Draw and No Win Condition
	$display("Testing Draw Condition");
	game_status = 32'd0;
	repeat(2) @(posedge clock);
	grid_full = 1'b1;
	game_status = {32'h66669999};
	repeat(10) @(posedge clock);
	if(winner == 2'b00) begin 
		$display("Success!");
	end else begin
		$display("Failure!: Winner =%d",winner);
		$stop;
	end
	grid_full = 1'b0;
	repeat(2) @(posedge clock);
	grid_full = 1'b1;
	game_status = {32'h99996666};
	repeat(10) @(posedge clock);
	if(winner == 2'b00) begin 
		$display("Success!");
	end else begin
		$display("Failure!: Winner =%d",winner);
		$stop;
	end
	grid_full = 1'b0;
	repeat(2) @(posedge clock);
	
	$display("****** ALL CONDITIONS TESTED SUCCESSFULLY ******");
	$display("%d ns\tSimulation Ended",$time); //Print Simulation End time to console
 end
 
 initial begin
	clock = 1'b0; //Initialise the clock to zero.
 end
 
 //Next we convert our clock period to nanoseconds and half it
 //to work out how long we must delay for each half clock cycle
 //Note how we convert the integer CLOCK_FREQ parameter it a real
 real HALF_CLOCK_PERIOD = (1e9 / $itor(CLOCK_FREQ)) / 2.0;
 
 //Now generate the clock
 integer half_cycles = 0;
 always begin
	 //Generate the next half cycle of clock
	 #(HALF_CLOCK_PERIOD);
	 //Delay for half a clock period.
	 clock = ~clock;
	 //Toggle the clock
	 half_cycles = half_cycles + 1; //Increment the counter
	 //Check if we have simulated enough half clock cycles
	 if (half_cycles == (2*NUM_CYCLES)) begin
	 //Once the number of cycles has been reached
	 half_cycles = 0;
	 //Reset half cycles
	 $stop;
	 //Break the simulation
	 //Note: We can continue the simualation after this breakpoint using
	 //"run -all", "run -continue" or "run ### ns" in modelsim.
	 end
 end
 
 endmodule
 