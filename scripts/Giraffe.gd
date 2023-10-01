extends Piece

class_name Giraffe

func get_possible_moves():
	return [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]

func get_type():
	return "Giraffe"
