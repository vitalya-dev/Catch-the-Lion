extends Node

const infinity = 1e9

func ai_turn(board_model, captured_pieces_model):
	print("Board model: ", board_model_to_string(board_model))  # Debugging line
	var best_score = -infinity
	var move = null

	for possible_move in all_possible_moves(board_model, captured_pieces_model, 1):
		print("AI considering move: ", possible_move)
		var result = simulate_move(board_model, captured_pieces_model, possible_move)
		var new_board_model = result["board"]
		var new_captured_pieces_model = result["captured"]
		print(board_model_to_string(new_board_model))
		var score = minimax(new_board_model, new_captured_pieces_model, 1, -1)
		if score > best_score:
			best_score = score
			move = possible_move
	print("So AI best move: ", move, " with score: ", best_score)
	return move

func minimax(board_model, captured_pieces_model, depth, player, alpha=-infinity, beta=infinity):
	if depth == 0 or game_over(board_model):
		return static_evaluation(board_model)

	var best_score = -infinity if player == 1 else infinity
	var best_move = null
	for possible_move in all_possible_moves(board_model, captured_pieces_model, player):
		var result = simulate_move(board_model, captured_pieces_model, possible_move)
		var new_board_model = result["board"]
		var new_captured_pieces_model = result["captured"]
		print("On that move player can answer ", possible_move)
		var score = minimax(new_board_model, new_captured_pieces_model, depth - 1, -player, alpha, beta)
		if player == 1 and score > best_score:
			best_score = score
			best_move = possible_move
			alpha = max(alpha, best_score)
		elif player == -1 and score < best_score:
			best_score = score
			best_move = possible_move
			beta = min(beta, best_score)

		if beta <= alpha:
			print("Pruning branches")  # Debugging line
			break

	print("So Player best answer is: ", best_move, " with score: ", best_score)
	return best_score


func all_possible_moves(board_model, captured_pieces_model, player):
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
	for piece in captured_pieces_model:
		if piece and piece["player"] == player:
			for j in range(len(board_model)):
				for k in range(len(board_model[j])):
					if board_model[j][k] == null:  # Only consider empty cells
						possible_moves.append({
							"piece": piece,
							"start_pos": null,  # Position where the piece is being placed
							"end_pos": Vector2(k, j)
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
		directions = [Vector2(0, 1)] if piece["player"] == 1 else [Vector2(0, -1)]
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

func deep_copy_board_model(board_model):
	var new_board_model = []
	for row in board_model:
		new_board_model.append(row.duplicate())
	return new_board_model


func is_chick(piece):
	return piece["type"] == "Chick"

func ai_reached_last_row(piece, end_pos, board_model):
	return piece["player"] == 1 and end_pos.y == len(board_model) - 1

func player_reached_first_row(piece, end_pos):
	return piece["player"] == -1 and end_pos.y == 0

func should_promote_to_hen(piece, end_pos, board_model):
	return is_chick(piece) and (ai_reached_last_row(piece, end_pos, board_model) or player_reached_first_row(piece, end_pos))

func simulate_move(board_model, captured_pieces_model, move):
	var new_board_model = deep_copy_board_model(board_model)
	var new_captured_pieces_model = captured_pieces_model.duplicate()
	var piece = move["piece"].duplicate()  # Create a copy of the piece
	var start_pos = move["start_pos"]
	var end_pos = move["end_pos"]
	
	if start_pos != null:  # If the piece is on the board
		new_board_model[start_pos.y][start_pos.x] = null
	else:  # If the piece is in the captured area
		new_captured_pieces_model.erase(piece)  # Remove the piece from the captured area

	if should_promote_to_hen(piece, end_pos, new_board_model):
		piece["type"] = "Hen"

	new_board_model[end_pos.y][end_pos.x] = piece
	
	return {"board": new_board_model, "captured": new_captured_pieces_model}


func static_evaluation(board_model):
	var score = 0
	var piece_values = {"Lion": 100, "Giraffe": 5, "Elephant": 5, "Chick": 1, "Hen": 10}

	for i in range(len(board_model)):
		for j in range(len(board_model[i])):
			var piece = board_model[i][j]
			if piece:
				var value = piece_values[piece["type"]]
				if piece["player"] == 1:
					score += value
				else:
					score -= value
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
	if lion1_pos == null or lion2_pos == null:
		print("Lion has been captured ", lion1_pos, lion2_pos)
		return true

	# Check if a lion has reached the opponent's den
	if lion1_pos.y == len(board_model) - 1 or lion2_pos.y == 0:
		print("Lion has reached the opponent's den ", lion1_pos, lion2_pos)
		return true

	return false


func generate_spaces(length):
	var spaces = ""
	for i in range(length):
		spaces += " "
	return spaces

func board_model_to_string(board_model):
	var board_string = "\n"
	var spaces = generate_spaces(15)
	board_string += spaces
	for i in range(len(board_model[0])):
		board_string += center_string(str(i), 15)
	board_string += "\n"
	for i in range(len(board_model)):
		var row = center_string(str(i), 15)
		for j in range(len(board_model[i])):
			var piece = board_model[i][j]
			if piece:
				var piece_string = piece["type"] + "(" + str(piece["player"]) + ")"
				row += center_string(piece_string, 15)  # Pad the string with spaces on the right to ensure it's 15 characters long
			else:
				row += center_string("Empty", 15)  # Pad the string "Empty" with spaces on the right to ensure it's 15 characters long
		board_string += row + "\n"
	return board_string

func center_string(s, width):
	var padding = max(0, width - s.length())
	var left_padding = padding / 2
	var right_padding = padding - left_padding
	return " ".lpad(left_padding) + s + " ".rpad(right_padding)
