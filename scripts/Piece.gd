extends Area3D

class_name Piece

signal piece_clicked

var is_selected = false
var mesh: MeshInstance3D
var original_color: Color

var original_transform: Transform3D
var original_parent: Node3D

enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = -1
}

var player : int :
	get:
		return Player.PLAYER_2 if transform.basis.z.z >= 0 else Player.PLAYER_1
	set (_value):
		pass

func _ready():
	input_event.connect(_on_piece_clicked)
	mesh = get_node("MeshInstance")
	original_color = mesh.get_active_material(0).albedo_color
	original_transform = transform
	original_parent = get_parent()

func highlight(select):
	mesh.get_active_material(0).albedo_color = original_color.lerp(Color.BLACK, 0.5) if select else original_color


func reset():
	reset_transform()
	reset_parent()
	highlight(false)
	set_input_ray_pickable(true)

func reset_transform():
	transform = original_transform

func reset_parent():
	if get_parent() != original_parent:
		get_parent().remove_child(self)
		original_parent.add_child(self)

func _on_piece_clicked(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		piece_clicked.emit(self)

func set_input_ray_pickable(enabled):
	input_ray_pickable = enabled

func get_possible_moves():
	return [Vector2(0, 0)]

func get_type():
	return ""