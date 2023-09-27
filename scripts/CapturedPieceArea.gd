extends Node3D

class_name CapturedPieceArea

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Add a piece to this node and layout all pieces
func add_piece(piece):
	piece.get_parent().remove_child(piece)
	self.add_child(piece)

	piece.rotate_y(deg_to_rad(180))
	
	layout_pieces()

# Layout the pieces in a grid
func layout_pieces():
	var num_captured_pieces = get_child_count()
	var grid_size = ceili(sqrt(num_captured_pieces))
	for i in range(num_captured_pieces):
		var piece = get_child(i)
		var x = i % grid_size
		var y = i / grid_size
		piece.transform.origin.x = x * -1 * piece.player
		piece.transform.origin.z = y * -1 * piece.player
		piece.transform.origin.y = 0

