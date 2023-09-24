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

func _place_captured_piece_on_board(grid_pos):
	var destination_piece = board.get_piece_at_grid_position(grid_pos)
	if destination_piece:
		print("Illegal move. Grid position already occupied.")
	else:
		board.add_piece(selected_piece)  # Add the piece to the board
		move_and_end_turn(grid_pos)

func _move_selected_piece_to_grid_position(grid_pos):
	var move = grid_pos - board.get_piece_grid_position(selected_piece)
	if move in selected_piece.get_possible_moves():
		var destination_piece = board.get_piece_at_grid_position(grid_pos)
		if destination_piece and destination_piece.player == selected_piece.player:
			print("Illegal move. Grid position already occupied by our player")
			return
		if destination_piece:
			var captured_pieces_area = captured_pieces_area_1 if selected_piece.player == Piece.Player.PLAYER_1 else captured_pieces_area_2
			captured_pieces_area.add_piece(destination_piece)
		move_and_end_turn(grid_pos)

func move_and_end_turn(grid_pos):
	selected_piece.global_transform.origin = board.grid_to_global(grid_pos)
	selected_piece.transform.origin.y = 0
	_on_piece_clicked(selected_piece)
	selected_piece = null
	switch_turns()

func switch_turns():
	current_turn = Piece.Player.PLAYER_2 if current_turn == Piece.Player.PLAYER_1 else Piece.Player.PLAYER_1
	for piece in board.get_pieces():
		piece.set_input_ray_pickable(piece.player == current_turn)
	for piece in captured_pieces_area_1.get_children():
		piece.set_input_ray_pickable(piece.player == current_turn)
	for piece in captured_pieces_area_2.get_children():
		piece.set_input_ray_pickable(piece.player == current_turn)


func _on_piece_clicked(piece):
	if piece.player == current_turn:
		if selected_piece:
			selected_piece.highlight(false)
		if selected_piece == piece:
			selected_piece = null
		else:
			piece.highlight(true)
			selected_piece = piece
