extends Sprite

onready var timer = $Timer

signal finish
func _ready():
	hide()
	timer.connect("timeout", self, "on_time_out")

func spawn(pos:Vector2):
	show()
	position = pos
	timer.start()

func on_time_out():
	emit_signal("finish")
	hide()
	
