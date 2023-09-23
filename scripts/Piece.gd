extends Area3D

class_name Piece

signal piece_clicked

var is_selected = false
var mesh: MeshInstance3D
var original_color: Color

enum Side {
    BLACK = -1,
    WHITE = 1
}

var side: int

func _ready():
	input_event.connect(_on_piece_clicked)
	mesh = get_node("MeshInstance")
	original_color = mesh.get_active_material(0).albedo_color
	side = Side.BLACK if transform.basis.z.z >= 0 else Side.WHITE

func highlight(select):
	mesh.get_active_material(0).albedo_color = original_color.lerp(Color.BLACK, 0.5) if select else original_color


func _on_piece_clicked(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		piece_clicked.emit(self)

func get_possible_moves():
	return [Vector2(0, 0)]
