extends ProgressBar

signal hit_finished()
var interval := 3

onready var timer := $Timer

func _ready():
	timer.connect("timeout", self, "on_time_out")
	hide()


func begin():
	show()
	value = 100
	timer.start(interval/float(100))
	
	
func on_time_out():
	value -= 1
	if value > 0:
		timer.start(interval / float(100))
	else:
		emit_signal("hit_finished")
	
