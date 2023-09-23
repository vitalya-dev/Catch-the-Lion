extends Piece

class_name Elephant

func get_possible_moves():
	return [Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)]
