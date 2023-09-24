extends Node3D

class_name Main

var selected_piece = null

@onready var board = $Board
@onready var captured_pieces_area_1 = $CapturedPieces/Player1
@onready var captured_pieces_area_2 = $CapturedPieces/Player2


var current_turn = Piece.Player.PLAYER_2

# Called when the node enters the scene tree for the first time.
func _ready():
	print_tree_pretty()
	board.board_clicked.connect(_on_board_clicked)
	for piece in board.get_pieces():
		piece.piece_clicked.connect(_on_piece_clicked)
		piece.set_input_ray_pickable(piece.player == current_turn)

func _on_board_clicked(grid_pos):
	if selected_piece:
		var piece_pos = board.get_piece_grid_position(selected_piece)
		var move = grid_pos - piece_pos
		if move in selected_piece.get_possible_moves():
			var destination_piece = board.get_piece_at_grid_position(grid_pos)
			if destination_piece and destination_piece.player == selected_piece.player:
				print("Illegal move. Grid position already occupied by our player")
				return
			if destination_piece:
				var captured_pieces_area = captured_pieces_area_1 if selected_piece.player == Piece.Player.PLAYER_1 else captured_pieces_area_2
				captured_pieces_area.add_piece(destination_piece)
			move_selected_piece_to_grid_position(grid_pos)
			_on_piece_clicked(selected_piece)
			switch_turns()

func switch_turns():
	current_turn = Piece.Player.PLAYER_2 if current_turn == Piece.Player.PLAYER_1 else Piece.Player.PLAYER_1
	for piece in board.get_pieces():
		piece.set_input_ray_pickable(piece.player == current_turn)
	for piece in captured_pieces_area_1.get_children():
		piece.set_input_ray_pickable(piece.player == current_turn)
	for piece in captured_pieces_area_2.get_children():
		piece.set_input_ray_pickable(piece.player == current_turn)

func move_selected_piece_to_grid_position(grid_pos):
	var global_pos = board.grid_to_global(grid_pos)
	selected_piece.global_transform.origin.x = global_pos.x
	selected_piece.global_transform.origin.z = global_pos.z
	selected_piece.transform.origin.y = 0


func _on_piece_clicked(piece):
	if piece.player == current_turn:
		if selected_piece:
			selected_piece.highlight(false)
		if selected_piece == piece:
			selected_piece = null
		else:
			piece.highlight(true)
			selected_piece = piece
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
