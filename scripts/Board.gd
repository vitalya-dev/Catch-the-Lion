extends Area3D

class_name Board

signal board_clicked

const BOARD_WIDTH = 3
const BOARD_HEIGHT = 4


# Called when the node enters the scene tree for the first time.
func _ready():
	input_event.connect(_on_board_clicked)

func _on_board_clicked(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_pos = global_to_grid(position)
		board_clicked.emit(grid_pos)

func is_within_bounds(grid_pos):
	return 0 <= grid_pos.x and grid_pos.x < BOARD_WIDTH and 0 <= grid_pos.y and grid_pos.y < BOARD_HEIGHT

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

func get_pieces():
	return get_node("Pieces").get_children()

func add_piece(piece):
	piece.get_parent().remove_child(piece)
	get_node("Pieces").add_child(piece)

func get_board_model():
	var model = []
	for i in range(BOARD_HEIGHT):
		var row = []
		for j in range(BOARD_WIDTH):
			var piece = get_piece_at_grid_position(Vector2(j, i))
			if piece:
				# If there's a piece at this position, add its type and player to the model
				row.append({"type": piece.get_type(), "player": piece.player})
			else:
				# If there's no piece at this position, add null to the model
				row.append(null)
		model.append(row)
	return model


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
