extends Node3D

class_name Main

var selected_piece = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$Board.board_clicked.connect(_on_board_clicked)
	for piece in get_node("Pieces").get_children():
		piece.piece_clicked.connect(_on_piece_clicked)

func _on_board_clicked(grid_pos):
	print(grid_pos)

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
