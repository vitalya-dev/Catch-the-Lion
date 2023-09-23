extends Node3D

class_name Main

var selected_piece = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$Board.board_clicked.connect(_on_board_clicked)
	for piece in get_node("Pieces").get_children():
		piece.piece_clicked.connect(_on_piece_clicked)

func _on_board_clicked(grid_pos):
	if selected_piece:
		move_selected_piece_to_grid_position(grid_pos)
		_on_piece_clicked(selected_piece)

func move_selected_piece_to_grid_position(grid_pos):
	var local_pos = Vector3(grid_pos.x - 1, 0, grid_pos.y - 1.5)
	var global_pos = $Board.to_global(local_pos)
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