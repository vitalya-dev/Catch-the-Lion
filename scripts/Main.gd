extends Node3D

class_name Main

var selected_piece = null

@onready var board = $Board
@onready var captured_pieces_area_1 = $CapturedPieces/Player1
@onready var captured_pieces_area_2 = $CapturedPieces/Player2

# Called when the node enters the scene tree for the first time.
func _ready():
	board.board_clicked.connect(_on_board_clicked)
	for piece in get_node("Board/Pieces").get_children():
		piece.piece_clicked.connect(_on_piece_clicked)

func _on_board_clicked(grid_pos):
	if selected_piece:
		var piece_pos = board.get_piece_grid_position(selected_piece)
		var move = grid_pos - piece_pos
		if move in selected_piece.get_possible_moves():
			var destination_piece = board.get_piece_at_grid_position(grid_pos)
			if destination_piece:
				if destination_piece.player == selected_piece.player:
					print("Illegal move. Grid position already occupied by our player")
				else:
					var captured_pieces_area = captured_pieces_area_1 if selected_piece.player == 1 else captured_pieces_area_2
					captured_pieces_area.add_piece(destination_piece)
					move_selected_piece_to_grid_position(grid_pos)
					_on_piece_clicked(selected_piece)
			else:
				move_selected_piece_to_grid_position(grid_pos)
				_on_piece_clicked(selected_piece)

func move_selected_piece_to_grid_position(grid_pos):
	var global_pos = board.grid_to_global(grid_pos)
	selected_piece.global_transform.origin.x = global_pos.x
	selected_piece.global_transform.origin.z = global_pos.z
	selected_piece.transform.origin.y = 0


func _on_piece_clicked(piece):
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
