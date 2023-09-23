extends Area3D

signal board_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	input_event.connect(_on_board_clicked)

func _on_board_clicked(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = to_local(position) + Vector3(1.5, 0, 2)
		var grid_pos = Vector2(local_pos.x, local_pos.z).floor()
		board_clicked.emit(grid_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
