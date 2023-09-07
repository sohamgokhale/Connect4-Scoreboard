/*
 * Check-connect module
 * ----------------------------
 * By: Soham Gokhale
 * For: University of Leeds - ELEC5566M
 * Date: 04 April 2023
 *
 * Description
 * ------------
 * This is a parameterised module that checks N 2-bit input to check 
 * if same player token is present in M occupied neighbouring cells.
 * It checks all possible combinations for both players.
 * This module uses combinational logic.
 *
 * Each cell can have below values:
 *			2'b00	=	Cell empty
 *			2'b01	=	Cell contains player 1 token
 *			2'b10	=	Cell contains player 2 token
 *			2'b11	=	XX
 *
 *	Parameters:
 *		WIDTH	: Integer value for no. of cells to check.
 *		CONN	: Integer value for no. of neigbouring cells 
 *				  that must have same token to win.
 *
 *	Inputs:
 *		cells	: Each cell contains 2-bit values. Total bus size = 2*WIDTH
 *	
 * Output:
 *		winner: Each bit represents if a player has won.
 *
 */
 
 
 module CheckConnect #(
	parameter WIDTH = 4,				// Integer value for no. of cells to check
	parameter CONN	 = 3				/* Integer value for no. of neigbouring cells 
												that must have same token to win */
 )(
	
	//Each cell contains 2-bit values. Total bus size = 2*WIDTH
	input		[(WIDTH*2)-1:0] 	cells,
	
	//Each bit represents if a player has won.
	output 	[1:0] 				winner
 );
 
 
 // Required wire declarations
 wire [WIDTH-1:0] p1_in;
 wire [WIDTH-1:0] p2_in;
 wire [WIDTH-CONN:0] p1_or;
 wire [WIDTH-CONN:0] p2_or;
 
 genvar i;	// Iterator for the generate block
 
 
/* The player tokens are represented by mutually 
 * exclusive bits in the cell.
 * 	2'b01	=	Cell contains player 1 token
 *	2'b10	=	Cell contains player 2 token
 * Therefore, by ANDing each players bits, we can see if a 
 * connection is made. If connection is made in any of the 
 * possible blocks (OR), a winner is declared.
 *
 */
 
 generate	// begin generate block
 
	 // Seperate P1 and P2 tokens from input cells
	 for(i=0; i<WIDTH;i=i+1) begin	: and_block
	 assign p1_in[i] = cells[2*i];
	 assign p2_in[i] = cells[(2*i)+1];
	 end
	 
	 // Check if a connection is made
	 for(i=0; i<=(WIDTH-CONN);i=i+1) begin		: or_block
	 assign p1_or[i] = &(p1_in[(i+CONN)-1:i]);
	 assign p2_or[i] = &(p2_in[(i+CONN)-1:i]);
	 end

	 // Declare winner if either possible location has a connection
	 assign winner[0] = |(p1_or); 
	 assign winner[1] = |(p2_or);
	 
 endgenerate
 endmodule
 