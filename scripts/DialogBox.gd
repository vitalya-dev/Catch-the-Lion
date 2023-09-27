extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func show_message(message):
	$MessageBackground/Message.text = message
	show()
	await $OkButton.pressed
	hide()