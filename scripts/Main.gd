extends Node3D

class_name Main

var selected_piece = null
var current_turn = Piece.Player.PLAYER_2

@onready var board = $Board
@onready var captured_pieces_area_1 = $CapturedPieces/Player1
@onready var captured_pieces_area_2 = $CapturedPieces/Player2

# Initialization and Connection Functions
func _ready():
	print_tree_pretty()
	board.board_clicked.connect(_on_board_clicked)
	_connect_piece_signals()
	update_piece_pickability()
	print(board.get_board_model())

func _connect_piece_signals():
	for piece in board.get_pieces():
		piece.piece_clicked.connect(_on_piece_clicked)

func _on_board_clicked(grid_pos):
	if selected_piece:
		_process_selected_piece_move(grid_pos)

func _on_piece_clicked(piece):
	if piece.player == current_turn and current_turn == Piece.Player.PLAYER_2:
		_handle_piece_click(piece)

# Piece Handling Functions
func _process_selected_piece_move(grid_pos):
	if selected_piece in captured_pieces_area_1.get_children() or selected_piece in captured_pieces_area_2.get_children():
		_place_captured_piece_on_board(grid_pos)
	else:
		_move_selected_piece_to_grid_position(grid_pos)

func _place_captured_piece_on_board(grid_pos):
	var destination_piece = board.get_piece_at_grid_position(grid_pos)
	if destination_piece:
		print("Illegal move. Grid position already occupied.")
	else:
		board.add_piece(selected_piece)  # Add the piece to the board
		move_piece_and_check_promotion(grid_pos)
		end_turn()

func _move_selected_piece_to_grid_position(grid_pos):
	var move = calculate_move(grid_pos)
	if is_valid_move(move):
		handle_valid_move(grid_pos)

func calculate_move(grid_pos):
	return grid_pos - board.get_piece_grid_position(selected_piece)

func is_valid_move(move):
	var destination_grid_pos = board.get_piece_grid_position(selected_piece) + move
	if not board.is_within_bounds(destination_grid_pos):
		return false
	var destination_piece = board.get_piece_at_grid_position(destination_grid_pos)
	return move in selected_piece.get_possible_moves() and (destination_piece == null or destination_piece.player != selected_piece.player)

func handle_valid_move(grid_pos):
	var destination_piece = board.get_piece_at_grid_position(grid_pos)
	if destination_piece:
		handle_destination_piece(destination_piece)
	move_piece_and_check_promotion(grid_pos)
	end_turn()

func handle_destination_piece(destination_piece):
	var captured_pieces_area = captured_pieces_area_1 if selected_piece.player == Piece.Player.PLAYER_1 else captured_pieces_area_2
	captured_pieces_area.add_piece(destination_piece)
	if destination_piece is ChickHen and destination_piece.state == ChickHen.State.HEN:
		destination_piece.demote_to_chick()

func move_piece_and_check_promotion(grid_pos):
	move_piece(grid_pos)
	check_promotion()

func move_piece(grid_pos):
	selected_piece.global_transform.origin = board.grid_to_global(grid_pos)
	selected_piece.transform.origin.y = 0

func check_promotion():
	var grid_pos = board.get_piece_grid_position(selected_piece)
	var is_chick = selected_piece is ChickHen and selected_piece.state == ChickHen.State.CHICK
	var reached_farthest_row = (selected_piece.player == Piece.Player.PLAYER_1 and grid_pos.y == 3) or (selected_piece.player == Piece.Player.PLAYER_2 and grid_pos.y == 0)
	if is_chick and reached_farthest_row:
		selected_piece.promote_to_hen()

func _handle_piece_click(piece):
	if selected_piece:
			selected_piece.highlight(false)
	if selected_piece == piece:
			selected_piece = null
	else:
			piece.highlight(true)
			selected_piece = piece

func check_win_conditions():
	var player_1_lion_exists = false
	var player_2_lion_exists = false

	for piece in board.get_pieces():
		if piece is Lion:
			if piece.player == Piece.Player.PLAYER_1:
				player_1_lion_exists = true
				if board.get_piece_grid_position(piece).y == 3:
					return Piece.Player.PLAYER_1
			elif piece.player == Piece.Player.PLAYER_2:
				player_2_lion_exists = true
				if board.get_piece_grid_position(piece).y == 0:
					return Piece.Player.PLAYER_2
	if not player_1_lion_exists:
		return Piece.Player.PLAYER_2
	elif not player_2_lion_exists:
		return Piece.Player.PLAYER_1
	return null

func reset_game():
	reset_pieces()
	reset_turn()
	deselect_piece()

func reset_pieces():
	for piece in board.get_pieces() + captured_pieces_area_1.get_children() + captured_pieces_area_2.get_children():
		piece.reset()

func reset_turn():
	current_turn = Piece.Player.PLAYER_2
	update_piece_pickability()

func deselect_piece():
	if selected_piece:
		selected_piece.highlight(false)
	selected_piece = null


func show_win_message(winner):
	var message = "Player " + str(winner) + " Wins!"
	await DialogBox.show_message(message)

# Turn Handling Functions
func end_turn():
	deselect_piece()
	var winner = check_win_conditions()
	if winner:
		await show_win_message(winner)
		reset_game()
	else:
		switch_turns()

func switch_turns():
	current_turn = Piece.Player.PLAYER_2 if current_turn == Piece.Player.PLAYER_1 else Piece.Player.PLAYER_1
	update_piece_pickability()
	if current_turn == Piece.Player.PLAYER_1:  # If it's AI's turn, make a move:
		ai_turn()

func update_piece_pickability():
	for piece in board.get_pieces() + captured_pieces_area_1.get_children() + captured_pieces_area_2.get_children():
		piece.set_input_ray_pickable(piece.player == current_turn)

# AI Functions
func ai_turn():
	print("AI's turn starts")
	var move_made = false
	while not move_made:
		selected_piece = _select_random_piece(Piece.Player.PLAYER_1)
		print("AI selected piece: ", selected_piece)
		move_made = try_random_moves_for_selected_piece()
		print("Move made: ", move_made)

func _select_random_piece(player):
	var player_pieces = []
	for piece in board.get_pieces():
		if piece.player == player:
			player_pieces.append(piece)
	return player_pieces[randi() % player_pieces.size()]


func try_random_moves_for_selected_piece():
	print("Trying random moves")
	var possible_moves = selected_piece.get_possible_moves()
	print("Possible moves: ", possible_moves)
	while possible_moves.size() > 0:
		var move_offset_index = randi() % possible_moves.size()
		var move_offset = possible_moves[move_offset_index]
		print("Trying move: ", move_offset)
		if is_valid_move(move_offset):
			print("Move is valid")
			var move_to_make = board.get_piece_grid_position(selected_piece) + move_offset
			_process_selected_piece_move(move_to_make)
			return true
		else:
			print("Move is not valid")
		possible_moves.remove_at(move_offset_index)
	print("Selected piece has no valid moves. Selecting a new piece.")
	return false
