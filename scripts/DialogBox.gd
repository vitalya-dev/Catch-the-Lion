extends ColorRect

signal restart_game



# Called when the node enters the scene tree for the first time.
func _ready():
	$RestartButton.pressed.connect(_on_RestartButton_pressed)

func show_message(message):
	$Message.text = message
	show()

func _on_RestartButton_pressed():
	hide()
	emit_signal("restart_game")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
