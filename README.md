# miniscript-alphabeta

_MiniScript code for the standard AI algorithm (Minimax with alpha-beta pruning) for 2-player deterministic games_

## What's all this, then?

This little one-file library contains code implementing a standard artificial intelligence (AI) algorithm called "minimax with alpha-beta pruning":

- _Minimax_: an algorithm which tries to minimize the opponent's score, and maximize its own score
- _alpha-beta pruning_: a simple enhancement to the above which allows the algorithm to skip exploring unprofitable parts of the search tree.

## When can I use it?

This algorithm works well for any 2-player, deterministic game.  These are games where the two players take turns altering the game state in some way, until one of them wins.  This includes most classic boardgames:

- Tic-Tac-Toe
- Checkers
- Chess
- Reversi/Othello
- Connect-4
- Ataxx/Spot
- etc.

## How do I use it?

1. `import "alphaBeta"` at the top of your script.  (After making sure alphaBeta.ms is somewhere in your import search path, of course.)

2. Create a subclass of alphaBeta.Node to represent the state of your game.  Your Node subclass must hold all the data defining the game state at a given point in time.  That means the placement of all the pieces in a board game, etc.

3. In your Node subclass, implement an `isGameOver` method that returns `true` when the game is over.

4. Also implement a `children` method that returns a list of new instances of your Node subclass, representing all the possible moves the player could make from that game state.

5. Finally, implement the `heuristicValue` method.  This should return a "score" for the current game state, which is positive for player 1, and negative for player 0.  This number should get bigger the closer the player is to winning.

6. Finally, to select the AI's move, call alphaBeta.alphaBeta for each possible move, passing in the current game state, a search depth (typically 3 to 8 or so), and some optional parameters that you usually don't need.  It will return a score for that move, taking into account possible future moves up to the given search depth.  Pick the one with the highest score, and play it!

In most games, steps 1-4 are pretty mechanical and straightforward, but step 5 — designing a heuristicValue function — is more involved, and leaves plenty of room for creativity.  The better your heuristic function is, the smarter your AI will be.

In the extreme case, your heuristic is perfect, always reporting whether any game state leads to a win or loss; in this case the AI will play perfectly with a search depth of only 1.  In the other extreme, your heuristic could return 0 until the game is actually over, reporting only on who won; in this case, the AI will essentially play at random until a win/loss is foreseeable within the search depth.

In more typical (and realistic) cases, you want to provide a heuristic function that gives some measure of how likely the game will result in a win for one player or another, even though this estimate is imperfect.  For example, in a Checkers game you might give some points (positive for player 1, negative for player 0) for each checker, and even more points for kings.  In a Chess game, you could award different point values for each piece, and also give some points based on position (for example, pawns advancing across the board).  However the heuristic function gets called for every game state the algorithm considers, so if it takes too long to compute, you won't be able to look ahead very far in a reasonable amount of time.  So: make it as accurate as you can, while still being quick to calculate.

## Examples

There are currently three examples included in this repo:

1. Matchstick game: this one is actually at the bottom of the `alphaBeta.ms` file itself, and runs if you load and run that file (rather than importing it).  Players take turns picking 1, 2, or 3 matchsticks from a pile.  The player who takes the last matchstick loses.
2. Tic-Tac-Toe: found in the demos folder, this is the classic game also known as "Naughts and Crosses", where players try to get 3 X's or O's in a row.
3. Connect-4: also in the demos folder, this is a game where you try to get 4 in a row, dropping checkers (or in this version, X's and O's) in from the top.

You can run these examples in Mini Micro or in command-line MiniScript.  Study these examples to see how they work — they're fairly short, and should be well commented.

## Questions?  Concerns?

The best way to get support is via Discord.  You can find the invitation link at the bottom of the [MiniScript home page](https://miniscript.org).

