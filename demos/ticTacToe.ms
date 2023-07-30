// Tic-Tac-Toe demo for alphaBeta module.
// This is the game sometimes known as Naughts and Crosses.
// Players take turns placing X's or O's on a 3x3 grid.
// First player to get 3 in a row wins.

// patch the import path so we can find alphaBeta
// in the parent directory
if version.hostName == "Mini Micro" then
	p = "/usr"
	if env.importPaths.indexOf(p) == null then
		env.importPaths.push p
	end if
else if version.hostName.indexOf("Command-Line") != null then
	p = "$MS_SCRIPT_DIR/.."
	if env.MS_IMPORT_PATH.indexOf(p) == null then
		env.MS_IMPORT_PATH += ":" + p
	end if
end if
import "alphaBeta"

// We'll represent the state with a 9-element list,
// indexed as follows:
//
//		0 | 1 | 2
//		---------
//		3 | 4 | 5
//		---------
//		6 | 7 | 8
//
// At each element we'll have ".", "X", or "O".
// Player 0 is "X" (minimizing), player 1 is "O" (maximizing).

TTTNode = new alphaBeta.Node
TTTNode.board = ["."]*9
TTTNode.winner = null		// "X" or "O" after win detected

TTTNode.print = function
	print self.board[0:3].join("|"); print "-----"
	print self.board[3:6].join("|"); print "-----"
	print self.board[6:9].join("|")
end function

TTTNode.isGameOver = function
	// game is over when there are no squares left,
	// or either side has won
	return self.winner or self.board.indexOf(".") == null
end function

TTTNode.makeChild = function(position)
	// Make a child node representing the state of the game
	// after the current player goes at the given position
	child = new TTTNode
	child.player = not self.player
	b = self.board[:]	// (copies the list)
	if self.player then b[position]="O" else b[position]="X"
	child.board = b
	// Note: it's important that all child nodes can correctly
	// report whether the game is over.  In this game, that is
	// somewhat hard to tell -- we discover it while calculating
	// the heuristic value.  But we don't want to do those
	// calculations multiple times.  So, right away when creating
	// a child node, let's call the heuristicValue function, and
	// then store the result on the child (hiding the function
	// reference).  This both sets child.winner, and ensures that
	// if the heuristic value is asked for again, we won't redo
	// the calculations.
	child.heuristicValue = child.heuristicValue
	return child
end function

TTTNode.children = function
	if self.winner then return []
	// Possible states result from going in any empty space.
	result = []
	for pos in range(0,8)
		if self.board[pos] == "." then
			result.push self.makeChild(pos)
		end if
	end for
	return result
end function

TTTNode.heuristicValue = function
	// Consider all possible 3-in-a-row sets of positions.
	// Give a heuristic value to each one with this helper:
	value = function(board, a,b,c)
		// give 1 point for a single piece with two empty spaces;
		// 10 points for two same-side pieces with an empty space;
		// and infinity (win/loss) for 3 same-side pieces.
		pA = board[a]
		pB = board[b]
		pC = board[c]
		// quick check for win/loss, and empty row
		if pA == "X" and pB == "X" and pC == "X" then return -alphaBeta.infinity
		if pA == "O" and pB == "O" and pC == "O" then return alphaBeta.infinity
		if pA == "." and pB == "." and pC == "." then return 0
		// join the pieces we found, sorted, for easier checking
		pieces = [pA, pB, pC].sort.join("")
		if pieces == ".XX" then return -10
		if pieces == ".OO" then return 10
		if pieces == "..X" then return -1
		if pieces == "..O" then return 1
		return 0
	end function
		
	// With that value function in hand, just add up the
	// value of all 3-in-a-row sets of positions.
	sum = value(self.board, 0, 1, 2) +
	      value(self.board, 3, 4, 5) +
	      value(self.board, 6, 7, 8) +
	      value(self.board, 0, 3, 6) +
	      value(self.board, 1, 4, 7) +
	      value(self.board, 2, 5, 8) +
	      value(self.board, 0, 4, 8) +
	      value(self.board, 2, 4, 6)
	if sum > 1E10 then
		self.winner = "O"
	else if sum < -1E10 then
		self.winner = "X"
	end if
	return sum
end function

// Let's play a game!  P0 = Human, P1 = AlphaBeta
curState = new TTTNode
while not curState.isGameOver
	curState.print
	if curState.player == 0 then
		while true
			position = input("Your move (0-8)? ").val
			if 0 <= position <= 8 and curState.board[position] == "." then break
		end while
		curState = curState.makeChild(position)
	else
		// We have to consider each possible move the
		// AI could make.  That's a little redundant
		// with the code in .children, but it keeps
		// the plumbing clean.
		bestMoves = []; bestScore = null
		for move in range(0,8)
			if curState.board[move] != "." then continue
			imagine = curState.makeChild(move)
			score = alphaBeta.alphaBeta(imagine, 5)
			print "If I go at " + move + ", my worst result is " + score
			if score == bestScore then
				bestMoves.push move
			else if not bestMoves or score > bestScore then
				print "    That's the best so far!"
				bestScore = score
				bestMoves = [move]
			end if
		end for
		pick = bestMoves[bestMoves.len * rnd]
		print "So, I will go at " + pick
		curState = curState.makeChild(pick)			
	end if
end while
curState.print
print "Game over!"
if curState.winner == "O" then
	print "I win!"
else if curState.winner == "X" then
	print "You win."
else
	print "It's a draw."
end if
