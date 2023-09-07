/*
 * CheckConnect Test Bench
 * ---------------------------
 *	By: Soham Gokhale
 *	For: University of Leeds - ELEC5566M
 *  Date: 04 Apr 2023
 * 
 *	Description
 * -----------
 *	Test bench for CheckConnect module.
 *
 */
 
  //Timescale declaration
 `timescale 1 ns/100 ps
 
 module CheckConnect_tb;
 
 reg  [7:0] 	cells4;	//	Status of all game values
 reg  [9:0] 	cells5;	//	Status of all game values
 reg  [13:0] 	cells7;	//	Status of all game values
 wire [1:0] 	winner4;
 wire [1:0] 	winner5;
 wire [1:0] 	winner7;
 
 CheckConnect #(
	.WIDTH 	(4),	// Integer value for no. of cells to check
	.CONN	(3)		/* Integer value for no. of neigbouring cells 
					   that must have same token to win */
 ) checkConnect_dut4(
	
	//Each cell contains 2-bit values. Total bus size = 2*WIDTH
	.cells	(cells4),
	
	//Each bit represents if a player has won.
	.winner	(winner4)
 );
 
 CheckConnect #(
	.WIDTH 	(5),	// Integer value for no. of cells to check
	.CONN	(4)		/* Integer value for no. of neigbouring cells 
					   that must have same token to win */
 ) checkConnect_dut5(
	
	//Each cell contains 2-bit values. Total bus size = 2*WIDTH
	.cells	(cells5),
	
	//Each bit represents if a player has won.
	.winner	(winner5)
 );
 
 CheckConnect #(
	.WIDTH 	(7),	// Integer value for no. of cells to check
	.CONN	(4)		/* Integer value for no. of neigbouring cells 
						that must have same token to win */
 ) checkConnect_dut7(
	
	//Each cell contains 2-bit values. Total bus size = 2*WIDTH
	.cells	(cells7),
	
	//Each bit represents if a player has won.
	.winner	(winner7)
 );
 
 
 initial begin
	//Print Simulation Start time to console
	$display("%d ns\tSimulation Started",$time);
	cells4 = {{(3){2'b10}},2'b00};
	cells5 = {{(4){2'b10}},2'b00};
	cells7 = {{(4){2'b10}},2'b00};
	#10;
	cells4 = {2'b00,{(3){2'b01}}};
	cells5 = {2'b00,{(4){2'b01}}};
	cells7 = {2'b00,{(4){2'b01}}};
	#10;
	
	cells4 = {{(3){2'b10}},2'b01};
	cells5 = {{(4){2'b10}},2'b01};
	cells7 = {{(4){2'b10}},2'b01};
	#10;
	cells4 = {2'b10,{(3){2'b01}}};
	cells5 = {2'b10,{(4){2'b01}}};
	cells7 = {2'b10,{(4){2'b01}}};
	#10;
	
	cells4 = {{(2){2'b10}},2'b01};
	cells5 = {{(3){2'b10}},2'b01};
	cells7 = {{(3){2'b10}},2'b01};
	#10;
	cells4 = {2'b10,{(2){2'b01}},2'b00};
	cells5 = {2'b10,{(3){2'b01}},2'b00};
	cells7 = {2'b10,{(3){2'b01}},2'b00};
	#10;

	//Print Simulation End time to console
	$display("%d ns\tSimulation Started",$time);
	
 end
 endmodule