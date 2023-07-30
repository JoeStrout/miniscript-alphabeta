// Connect-4 game.
// Players take turns dropping a checker in from the top of the board,
// whereupon it slides down as far as it can.
// First player to get 4 in a row wins.

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
import "listUtil"

infinity = alphaBeta.infinity

rowCount = 6
colCount = 7

BoardNode = new alphaBeta.Node
BoardNode.pieces = null	// 2D [row][col] array of ".", "X", or "O"
BoardNode.player = 0	// 0 for X (minimizer), 1 for O (maximizer)
BoardNode.winner = 0	// 1 for X, 2 for O
BoardNode.initToStartingState = function
	self.pieces = list.init2d(rowCount, colCount, ".")
end function

BoardNode.print = function
	for row in range(rowCount-1)
		for col in range(0, colCount-1)
			print self.pieces[row][col], " "
		end for
		print
	end for
	print ("+-" * colCount)[:-1]
	print range(0, colCount-1).join
end function

BoardNode.makeChild = function(columnToPlay)
	p = self.pieces
	row = rowCount - 1
	while row > 0 and p[row-1][columnToPlay] == "."; row -= 1; end while
	child = new BoardNode
	child.pieces = self.pieces.deepCopy
	child.pieces[row][columnToPlay] = "XO"[self.player]
	child.player = not self.player
	// precompute winner (ToDo: heuristic value only)
	child.winner = child.winner
	child.heuristicValue = child.heuristicValue
	return child
end function

// get child states of this node (i.e., states that represent
// the game after all possible moves of self.player)
BoardNode.children = function
	result = []
	p = self.pieces
	nextPlayer = not self.player
	for col in range(0, colCount-1)
		if p[rowCount-1][col] != "." then continue
		result.push self.makeChild(col)
	end for
	return result
end function

// Given coordinates of four spaces in a row, return
// a score (positive for O, negative for X).
BoardNode.scorePiecesInRow = function(xy0, xy1, xy2, xy3)
	p = self.pieces
	// Gather the four pieces, sort them, and join them into a string.
	// This makes it much easier to check for all the possible cases.
	pieces = [ p[xy0[0]][xy0[1]], p[xy1[0]][xy1[1]],
	   p[xy2[0]][xy2[1]], p[xy3[0]][xy3[1]] ].sort.join("")
	if pieces == "...." then return 0
	if pieces == "XXXX" then 
		self.winner = 1
		return -infinity
	else if pieces == "OOOO" then
		self.winner = 2
		return infinity
	end if
	if pieces == ".XXX" then return -100
	if pieces == ".OOO" then return 100
	if pieces == "..XX" then return -10
	if pieces == "..OO" then return 10
	if pieces == "...X" then return -1
	if pieces == "...O" then return 1	
	return 0
end function

// get the heuristic value of this game state (< 0 if player 0
// is winning, > 0 if player 1 is winning)
BoardNode.heuristicValue = function
	score = 0
	// horizontal
	for y in range(0, rowCount-1)
		for x in range(0, colCount-4)
			score += self.scorePiecesInRow([y,x], [y,x+1], [y,x+2], [y,x+3])
		end for
	end for
	// vertical
	for y in range(0, rowCount-4)
		for x in range(0, colCount-1)
			score += self.scorePiecesInRow([y,x], [y+1,x], [y+2,x], [y+3,x])
		end for
	end for
	// diagonal up/right
	for y in range(0, rowCount-4)
		for x in range(0, colCount-4)
			score += self.scorePiecesInRow([y,x], [y+1,x+1], [y+2,x+2], [y+3,x+3])
		end for
	end for
	// diagonal down/right
	for y in range(3, rowCount-1)
		for x in range(0, colCount-4)
			score += self.scorePiecesInRow([y,x], [y-1,x+1], [y-2,x+2], [y-3,x+3])
		end for
	end for
	return score
end function

// return whether the game is over
BoardNode.isGameOver = function
	return self.winner > 0
end function


// Let's play a game!  P0 = Human, P1 = AlphaBeta
curState = new BoardNode
curState.initToStartingState
while not curState.isGameOver
	curState.print
	if curState.player == 0 then
		while true
			position = input("Your move (0-" + (colCount-1) + ")? ").val
			if 0 <= position < colCount and curState.pieces[rowCount-1][position] == "." then break
		end while
		curState = curState.makeChild(position)
	else
		// We have to consider each possible move the
		// AI could make.  That's a little redundant
		// with the code in .children, but it keeps
		// the plumbing clean.
		bestMoves = []; bestScore = null
		for move in range(0, colCount-1)
			if curState.pieces[rowCount-1][move] != "." then continue
			imagine = curState.makeChild(move)
			score = alphaBeta.alphaBeta(imagine, 3)
			print "If I go at " + move + ", my worst result is " + score, ""
			if score == bestScore then
				bestMoves.push move
				print "    (also good)"
			else if not bestMoves or score > bestScore then
				print "    (New best!)"
				bestScore = score
				bestMoves = [move]
			else
				print
			end if
		end for
		if not bestMoves then
			print "I have no legal moves."
			break
		end if
		pick = bestMoves[bestMoves.len * rnd]
		print "So, I will go at " + pick
		curState = curState.makeChild(pick)			
	end if
end while
curState.print
print "Game over!"
if curState.winner == 2 then
	print "I win!"
else if curState.winner == 1 then
	print "You win."
else
	print "It's a draw."
end if
