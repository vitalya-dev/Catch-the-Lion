extends Node

const infinity = 1e9

func ai_turn(board_model):
	var best_score = -infinity
	var move = null

	for possible_move in all_possible_moves(board_model, 1):
		var new_board_model = simulate_move(board_model, possible_move)
		var score = minimax(new_board_model, 0, -1)
		print("Possible move: ", possible_move, " Score: ", score)
		if score > best_score:
			best_score = score
			move = possible_move

	print("Best move: ", move, " Best score: ", best_score)
	return move

func minimax(board_model, depth, player, alpha=-infinity, beta=infinity):
	if depth == 0 or game_over(board_model):
		return static_evaluation(board_model)

	var best_score = -infinity if player == 1 else infinity

	for possible_move in all_possible_moves(board_model, player):
		var new_board_model = simulate_move(board_model, possible_move)
		var score = minimax(new_board_model, depth - 1, -player, alpha, beta)
		print("Move: ", possible_move, " Score: ", score)
		if player == 1:
			best_score = max(score, best_score)
			alpha = max(alpha, best_score)
		else:
			best_score = min(score, best_score)
			beta = min(beta, best_score)

		if beta <= alpha:
			break

	return best_score

func all_possible_moves(board_model, player):
	var possible_moves = []
	for i in range(len(board_model)):
		for j in range(len(board_model[i])):
			var piece = board_model[i][j]
			if piece and piece["player"] == player:
				var piece_moves = get_piece_moves(piece, Vector2(j, i), board_model)
				for move in piece_moves:
					possible_moves.append({
						"piece": piece,
						"start_pos": Vector2(j, i),
						"end_pos": move
					})
	return possible_moves

func get_piece_moves(piece, pos, board_model):
	var moves = []
	var directions = []

	if piece["type"] == "Elephant":
		directions = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
	elif piece["type"] == "Giraffe":
		directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
	elif piece["type"] == "Lion":
		directions = [Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)]
	elif piece["type"] == "Chick":
		directions = [Vector2(0, -1)] if piece["player"] == 1 else [Vector2(0, 1)]
	elif piece["type"] == "Hen":
		if piece["player"] == 1:
			directions =  [Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1),  Vector2(-1, 1), Vector2(1, 1)]
		else:
			directions =  [Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1),  Vector2(-1, -1), Vector2(1, -1)]

	for direction in directions:
		var move_pos = pos + direction
		if is_within_board(move_pos, board_model):
			var target_piece = board_model[move_pos.y][move_pos.x]
			if not target_piece or target_piece["player"] != piece["player"]:
				moves.append(move_pos)

	return moves



func simulate_move(board_model, move):
	var new_board_model = board_model.duplicate()
	var piece = move["piece"]
	var start_pos = move["start_pos"]
	var end_pos = move["end_pos"]
	
	new_board_model[start_pos.y][start_pos.x] = null
	new_board_model[end_pos.y][end_pos.x] = piece
	
	return new_board_model

func static_evaluation(board_model):
	var score = 0
	for i in range(len(board_model)):
		for j in range(len(board_model[i])):
			var piece = board_model[i][j]
			if piece:
				if piece["player"] == 1:
					score += 1
				else:
					score -= 1
	return score

func is_within_board(pos, board_model):
	return pos.y >= 0 and pos.y < len(board_model) and pos.x >= 0 and pos.x < len(board_model[0])

func game_over(board_model):
	var lion1_pos = null
	var lion2_pos = null

	for i in range(len(board_model)):
		for j in range(len(board_model[i])):
			var piece = board_model[i][j]
			if piece and piece["type"] == "Lion":
				if piece["player"] == 1:
					lion1_pos = Vector2(j, i)
				else:
					lion2_pos = Vector2(j, i)

	# Check if either lion has been captured
	if not lion1_pos or not lion2_pos:
		return true

	# Check if a lion has reached the opponent's den
	if lion1_pos.y == len(board_model) - 1 or lion2_pos.y == 0:
		return true

	return false