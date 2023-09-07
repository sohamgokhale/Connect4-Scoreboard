/*
 * Scoreboard block
 * ----------------------------
 * By: Soham Gokhale
 * For: University of Leeds - ELEC5566M-Mini-Project-Group-6
 * Date: 04 April 2023
 *
 * Description
 * ------------
 * The module checks the game grid to check if a player has won the round.
 * It also tracks the number rounds each player has won.
 * Every 2-bits of the bus represent one cell in this grid.
 * Each cell can have below values:
 *			2'b00	=	Cell empty
 *			2'b01	=	Cell contains player 1 token
 *			2'b10	=	Cell contains player 2 token
 *			2'b11	=	XX
 *
 */


 module Scoreboard #(
	parameter ROWS = 4,		// Number of Rows in the game grid
	parameter COLS = 4,		// Number of Columns in the game grid
	parameter CONN = 3		// Connect count required to win. Eg. Connect 3, Connect 4 etc.
 )(

	input 	clock,			// Input Clock Signal
	input 	reset,			//	Global reset. Resets all scores
	input		grid_full,		// Input signal. High signifies grid is full

	//	Status of all game values
	input [(2*ROWS*COLS)-1:0] 	game_status,

	output reg  [1:0]		winner,		// Round winner
	output wire [7:0] 	p1_score,	// Rounds won by Player 1
	output wire [7:0] 	p2_score,	// Rounds won by Player 2
	output wire [7:0] 	draw_score	// Rounds ended in a draw
 );

 localparam dROWS_MAX = (ROWS-(CONN-1));
 localparam dCOLS_MAX = (COLS-(CONN-1));

 // Wires of appropriate width used to store results of CheckConnect submodules
 wire [ROWS-1:0] win_p1_h;
 wire [ROWS-1:0] win_p2_h;
 wire [COLS-1:0] win_p1_v;
 wire [COLS-1:0] win_p2_v;

 wire [(ROWS*COLS)-1:0] win_p1_d_up;
 wire [(ROWS*COLS)-1:0] win_p2_d_up;

 wire [(ROWS*COLS)-1:0] win_p1_d_dw;
 wire [(ROWS*COLS)-1:0] win_p2_d_dw;

 // Wire vector array used to divide the input bus by rows
 wire [(2*COLS)-1:0] row_vect [ROWS-1:0];

 // Wire vector array used to divide the input bus by columns
 wire [(2*ROWS)-1:0] col_vect [COLS-1:0];
 wire [(2*ROWS)-1:0] col_flip [COLS-1:0];

 wire [(2*CONN)-1:0] diag_up [dROWS_MAX-1:0][dCOLS_MAX-1:0];
 wire [(2*CONN)-1:0] diag_dw [dROWS_MAX-1:0][dCOLS_MAX-1:0];

 genvar i,j,k;	// genvar variables for generate blocks

/* Generate blocks are used to conditionally generate submodules.
 * As this module parameterised, the no. of sub-modules to be initialised
 * depends on the no. of ROWS and COLS of the game.
 */

/************************************************************************/
/*********************** CHECK HORIZONTAL CONNECT ***********************/
/************************************************************************/

/* Below generate block is used to selectively separate the bits of the
 * game_status input bus that represent each column of the game grid.
 * This will make it easier to check if there are any vertical or diagonal
 * connects present in the game grid.
 */
 generate
	for(i=0;i<ROWS;i=i+1) begin	:	gen_row_vect1
		for(j=0;j<COLS;j=j+1) begin	:	gen_row_vect2
			assign row_vect[i][(2*j)+:2] = game_status[((2*ROWS)*j)+(2*i)+:2];
		end
	end
 endgenerate

/* Below generate block is used to instantiate CheckConnect module
 * for each row of the game grid. This will check if there are any
 * horizontal connects present in the game and if yes will return
 * the winner
 */
 generate
	for(i=0;i<ROWS;i=i+1) begin	:	check_horizontal
		CheckConnect #(
			.WIDTH	(COLS),		// Set Width = No. of Columns as we are checking horizontally
			.CONN		(CONN)		// Set Connect length
		) check_horz (
			.cells	(row_vect[i]),	// Send one row to each instance
			.winner	({win_p2_h[i],win_p1_h[i]})				//	Collect result in wires
		);
	end
 endgenerate

 /************************************************************************/
 /************************ CHECK VERTICAL CONNECT ************************/
 /************************************************************************/

/* Below generate block is used to selectively separate the bits of the
 * game_status input bus that represent each column of the game grid.
 * This will make it easier to check if there are any vertical or diagonal
 * connects present in the game grid.
 */
 generate
	for(i=0;i<COLS;i=i+1) begin	:	gen_col_vect1
			assign col_vect[i] = game_status[(2*ROWS*i)+:(2*ROWS)];
	end
 endgenerate


/* Below generate block is used to instantiate CheckConnect module for
 * each column of the game grid. This will check if there are any vertical
 * connects present in the game and if yes will return the winner
 */
 generate
	for(j=0;j<COLS;j=j+1) begin	:	check_vertical
		CheckConnect #(
			.WIDTH	(ROWS),		// Set Width = No. of Rows as we are checking vertically
			.CONN		(CONN)		// Set Connect length
		) check_vert (
			.cells	(col_vect[j]),						// Send one column to each instance
			.winner	({win_p2_v[j],win_p1_v[j]})	// Collect result in wires
		);
	end
 endgenerate

 /************************************************************************/
 /********************** CHECK UP DIAGONAL CONNECT ***********************/
 /************************************************************************/

/* Below generate block is used to selectively separate the bits of the
 * game_status input bus that represent an upward diagonal of the game grid
 * where a connect is possible. This will be used to check if there are any
 * diagonal connects present in the game grid.
 */
 generate
	for(i=0;i<(dROWS_MAX);i=i+1) begin		:gen_diag_up1
		for(j=0;j<(dCOLS_MAX);j=j+1) begin	:gen_diag_up2
			for(k=j;k<(CONN+j);k=k+1) begin		:gen_diag_up3
				assign diag_up[i][j][(2*(k-j))+:2] = col_vect[k][(2*(k-j+i))+:2];
			end
		end
	end
 endgenerate


/* Below generate block is used to instantiate CheckConnect module for
 * each upward diagonal of the game grid. This will check if there are any
 * diagonal connects present in the game and if yes will return the winner
 */
 generate
	for(i=0;i<(dROWS_MAX);i=i+1) begin	:	check_diag1
		for(j=0;j<(dCOLS_MAX);j=j+1) begin	:	check_diag2
			CheckConnect #(
				.WIDTH	(CONN),		// Set Width = Connect length as we are checking diagonally
				.CONN	(CONN)		// Set Connect length
			) check_diag_up (
				.cells	(diag_up[i][j]),	// Send one diagonal to each instance
				.winner	({win_p2_d_up[(dCOLS_MAX*i)+j],win_p1_d_up[(dCOLS_MAX*i)+j]})
			);
		end
	end
 endgenerate


 /************************************************************************/
 /********************** CHECK DOWN DIAGONAL CONNECT *********************/
 /************************************************************************/

// Below block flips the column vector to enable detecting downward diagonals
 generate
	for(i=0;i<COLS;i=i+1) begin		:	gen_col_flip1
		for(j=0;j<ROWS;j=j+1) begin	:	gen_col_flip2
			assign col_flip[i][(2*j)+:2] = col_vect[i][2*((ROWS-1)-j)+:2];
		end
	end
 endgenerate

/* Below generate block is used to selectively separate the bits of the
 * game_status input bus that represent an downward diagonal of the game grid
 * where a connect is possible. This will be used to check if there are any
 * diagonal connects present in the game grid.
 */
 generate
	for(i=0;i<(dROWS_MAX);i=i+1) begin		:gen_diag_dw1
		for(j=0;j<(dCOLS_MAX);j=j+1) begin	:gen_diag_dw2
			for(k=j;k<(CONN+j);k=k+1) begin		:gen_diag_dw3
				assign diag_dw[i][j][(2*(k-j))+:2] = col_flip[k][(2*(k-j+i))+:2];
			end
		end
	end
 endgenerate

/* Below generate block is used to instantiate CheckConnect module for
 * each downward diagonal of the game grid. This will check if there are any
 * diagonal connects present in the game and if yes will return the winner
 */
 generate
	for(i=0;i<(dROWS_MAX);i=i+1) begin	:	check_diag_d3
		for(j=0;j<(dCOLS_MAX);j=j+1) begin	:	check_diag_d4
			CheckConnect #(
				.WIDTH	(CONN),		// Set Width = Connect length as we are checking diagonally
				.CONN	(CONN)		// Set Connect length
			) check_diag_down (
				.cells	(diag_dw[i][j]),	// Send one diagonal to each instance
				.winner	({win_p2_d_dw[(dCOLS_MAX*i)+j],win_p1_d_dw[(dCOLS_MAX*i)+j]})
			);
		end
	end
 endgenerate


 /************************************************************************/
 /**************************** PROCEDURAL BLOCK **************************/
 /************************************************************************/
 // Procedural initial block
 initial begin
	winner 		<= 2'b00;
 end

 // Procedural always block
 always @(posedge clock or posedge reset) begin
	if(reset) begin
		winner <= 2'b00;
	end else begin
	 /*Check if win condition has been met by P1 anywhere in the grid by simple OR logic.
		The result is assigned to bit 0 of output bus 'winner'*/
		if((| win_p1_h) | (| win_p1_v) | (|win_p1_d_up) | (|win_p1_d_dw)) begin
			winner[0] <= 1'b1;
		end else begin
			winner[0] <= 1'b0;
		end

	 /*Check if win condition has been met by P2 anywhere in the grid by simple OR logic.
		The result is assigned to bit 1 of output bus 'winner'*/
		if ((| win_p2_h) | (| win_p2_v) | (|win_p2_d_up) | (|win_p2_d_dw)) begin
			winner[1] <= 1'b1;
		end else begin
			winner[1] <= 1'b0;
		end
	end
 end

 /************************************************************************/
 /***************************** SCORE KEEPER *****************************/
 /************************************************************************/

 ScoreKeeper scorekeeper(
 .clock		(clock		),
 .reset		(reset		),
 .grid_full	(grid_full	),
 .winner		(winner		),

 .p1_score	(p1_score	),	// Rounds won by Player 1
 .p2_score	(p2_score	),	// Rounds won by Player 2
 .draw_score(draw_score	)	// Rounds ended in a draw
 );

 endmodule


 module ScoreKeeper(
 input 			clock,
 input 			reset,
 input 			grid_full,
 input [1:0]	winner,

 output reg [7:0] 	p1_score,	// Rounds won by Player 1
 output reg [7:0] 	p2_score,	// Rounds won by Player 2
 output reg [7:0] 	draw_score	// Rounds ended in a draw

 );

 reg [7:0] 	p1_count;	// Rounds won by Player 1
 reg [7:0] 	p2_count;	// Rounds won by Player 2
 reg [7:0] 	draw_count;	// Rounds ended in a draw

 initial begin
	p1_count = 8'b00000000;
	p2_count = 8'b00000000;
	draw_count = 8'b00000000;

	p1_score 	= 8'b00000000;
	p2_score 	= 8'b00000000;
	draw_score 	= 8'b00000000;
 end
 
 always @(posedge clock) begin
	p1_score 	<= p1_count;
	p2_score 	<= p2_count;
	draw_score 	<= draw_count;
 end

 always @(posedge winner[0]) begin
		p1_count = p1_count + 1;
 end
 
 always @(posedge winner[1]) begin
		p2_count = p2_count + 1;
 end
 
 always @(posedge grid_full) begin
	if(winner == 2'b00) begin
		draw_count = draw_count + 1;
	end
 end

 endmodule
