extends Piece

class_name Lion

func get_possible_moves():
	return [
		Vector2(1 , 1), Vector2(-1 , -1), Vector2(1 , -1), Vector2(-1 , 1), 
		Vector2(0, 1), Vector2(0, -1), Vector2(1 , 0), Vector2(-1 , 0)
	]
