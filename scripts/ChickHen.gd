extends Piece

class_name ChickHen

enum State {CHICK, HEN}

var state = State.CHICK

func get_possible_moves():
	if state == State.CHICK:
		return [Vector2(0, 1 * player)]
	else:
		return [Vector2(0, 1 * player), Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1 * player),  Vector2(-1, 1 * player), Vector2(1, 1 * player)]

func promote_to_hen():
	state = State.HEN
	self.rotate_z(deg_to_rad(180))

func demote_to_chick():
	state = State.CHICK
	self.rotate_z(deg_to_rad(180))

func highlight(select):
	super.highlight(select)
	mesh.get_active_material(1).albedo_color = original_color.lerp(Color.BLACK, 0.5) if select else original_color


func reset():
	super.reset()
	state = State.CHICK
