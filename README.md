# Connect4-Scoreboard
---

Module to check if a win condition has been satisfied for a connect four game. This was developed as a part of a group project for University of Leeds ELEC5566M Module coursework. The full project consisted of a complete connect four game running on DE1-SoC. 

The scoreboard module also contains a scorekeeper to keep track of each players wins. The logic has been tested in simulation using the test benches and also on the DE1-SoC hardware.

## Features
* Fully Parameterised for grid size and connect count.
* Check in horizontal, vertical and both diagonal directions.
* Persists player scores across game resets.

## File Descriptions

| File | Purpose |
| ---  | --- |
| `Scoreboard.v`      | The module checks the game grid (input) to check if a player has won the round. It also tracks the number rounds each player has won. |
| `CheckConnect.v`       | Parameterised module that checks N 2-bit inputs to check if same player piece is present in M occupied neighbouring cells. It checks all possible combinations for both players. This module uses combinational logic. |
| `Scoreboard_tb.v` | Test bench for Scoreboard module.  |
| `CheckConnect_tb.v` | Test bench for CheckConnect module.  |

