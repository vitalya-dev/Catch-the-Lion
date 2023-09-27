extends Node3D

class_name Main

var selected_piece = null
var current_turn = Piece.Player.PLAYER_2

@onready var board = $Board
@onready var captured_pieces_area_1 = $CapturedPieces/Player1
@onready var captured_pieces_area_2 = $CapturedPieces/Player2

func _ready():
	print_tree_pretty()
	board.board_clicked.connect(_on_board_clicked)
	_connect_piece_signals()

func _connect_piece_signals():
	for piece in board.get_pieces():
		piece.piece_clicked.connect(_on_piece_clicked)
		piece.set_input_ray_pickable(piece.player == current_turn)

func _on_board_clicked(grid_pos):
	if selected_piece:
		_handle_selected_piece(grid_pos)

func _handle_selected_piece(grid_pos):
	if selected_piece in captured_pieces_area_1.get_children() or selected_piece in captured_pieces_area_2.get_children():
		_place_captured_piece_on_board(grid_pos)
	else:
		_move_selected_piece_to_grid_position(grid_pos)

func move_piece_and_check_promotion(grid_pos):
	move_piece(grid_pos)
	check_promotion()
	end_turn()

func _place_captured_piece_on_board(grid_pos):
	var destination_piece = board.get_piece_at_grid_position(grid_pos)
	if destination_piece:
		print("Illegal move. Grid position already occupied.")
	else:
		board.add_piece(selected_piece)  # Add the piece to the board
		move_piece_and_check_promotion(grid_pos)

func check_win_conditions():
	var player_1_lion_exists = false
	var player_2_lion_exists = false

	for piece in board.get_pieces():
		if piece is Lion:
			if piece.player == Piece.Player.PLAYER_1:
				player_1_lion_exists = true
				if board.get_piece_grid_position(piece).y == 3:
					await DialogBox.show_message("Player 1 Wins by Invasion!")
					reset_game()
					return
			elif piece.player == Piece.Player.PLAYER_2:
				player_2_lion_exists = true
				if board.get_piece_grid_position(piece).y == 0:
					await DialogBox.show_message("Player 2 Wins by Invasion!")
					reset_game()
					return
	if not player_1_lion_exists:
		await DialogBox.show_message("Player 2 Wins by Capturing the Lion!")
		reset_game()
	elif not player_2_lion_exists:
		await DialogBox.show_message("Player 1 Wins by Capturing the Lion!")
		reset_game()

func _move_selected_piece_to_grid_position(grid_pos):
	var move = calculate_move(grid_pos)
	if is_valid_move(move):
		handle_valid_move(grid_pos)

func calculate_move(grid_pos):
	return grid_pos - board.get_piece_grid_position(selected_piece)

func is_valid_move(move):
	return move in selected_piece.get_possible_moves()

func handle_valid_move(grid_pos):
	var destination_piece = board.get_piece_at_grid_position(grid_pos)
	if destination_piece and destination_piece.player == selected_piece.player:
		print("Illegal move. Grid position already occupied by our player")
		return
	if destination_piece:
		handle_destination_piece(destination_piece)
	move_piece_and_check_promotion(grid_pos)

func handle_destination_piece(destination_piece):
	var captured_pieces_area = captured_pieces_area_1 if selected_piece.player == Piece.Player.PLAYER_1 else captured_pieces_area_2
	captured_pieces_area.add_piece(destination_piece)
	if destination_piece is ChickHen and destination_piece.state == ChickHen.State.HEN:
		destination_piece.demote_to_chick()

func reset_game():
	reset_pieces()
	reset_turn()
	deselect_piece()

func reset_pieces():
	for piece in board.get_pieces():
		piece.reset()
	for piece in captured_pieces_area_1.get_children():
		piece.reset()
	for piece in captured_pieces_area_2.get_children():
		piece.reset()

func reset_turn():
	current_turn = Piece.Player.PLAYER_2
	for piece in board.get_pieces():
		piece.set_input_ray_pickable(piece.player == current_turn)

func deselect_piece():
	selected_piece = null

func check_promotion():
	var grid_pos = board.get_piece_grid_position(selected_piece)
	var is_chick = selected_piece is ChickHen and selected_piece.state == ChickHen.State.CHICK
	var reached_farthest_row = (selected_piece.player == Piece.Player.PLAYER_1 and grid_pos.y == 3) or (selected_piece.player == Piece.Player.PLAYER_2 and grid_pos.y == 0)
	if is_chick and reached_farthest_row:
		selected_piece.promote_to_hen()

func move_piece(grid_pos):
	selected_piece.global_transform.origin = board.grid_to_global(grid_pos)
	selected_piece.transform.origin.y = 0

func switch_turns():
	current_turn = Piece.Player.PLAYER_2 if current_turn == Piece.Player.PLAYER_1 else Piece.Player.PLAYER_1
	for piece in board.get_pieces():
		piece.set_input_ray_pickable(piece.player == current_turn)
	for piece in captured_pieces_area_1.get_children():
		piece.set_input_ray_pickable(piece.player == current_turn)
	for piece in captured_pieces_area_2.get_children():
		piece.set_input_ray_pickable(piece.player == current_turn)

func end_turn():
	_on_piece_clicked(selected_piece)
	check_win_conditions()
	switch_turns()

func _on_piece_clicked(piece):
	if piece.player == current_turn:
		if selected_piece:
			selected_piece.highlight(false)
		if selected_piece == piece:
			selected_piece = null
		else:
			piece.highlight(true)
			selected_piece = piece
