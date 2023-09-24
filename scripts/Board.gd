extends Area3D

class_name Board

signal board_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	input_event.connect(_on_board_clicked)

func _on_board_clicked(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_pos = global_to_grid(position)
		board_clicked.emit(grid_pos)

func get_piece_grid_position(piece):
	return global_to_grid(piece.global_transform.origin)

func global_to_grid(global_pos):
	var local_pos = to_local(global_pos) + Vector3(1.5, 0, 2)
	return Vector2(local_pos.x, local_pos.z).floor()

func grid_to_global(grid_pos):
	var local_pos = Vector3(grid_pos.x - 1, 0, grid_pos.y - 1.5)
	return to_global(local_pos)

func get_piece_at_grid_position(grid_pos):
	# Loop through all the pieces on the board
	for piece in get_node("Pieces").get_children():
		# Get the grid position of each piece
		var piece_grid_pos = get_piece_grid_position(piece)
		# If the grid position matches the input, return the piece
		if piece_grid_pos == grid_pos:
			return piece
	# If no piece is found, return null
	return null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
