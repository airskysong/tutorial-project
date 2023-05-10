extends Node2D

signal finished

#var move_time = 1.0
#var height = 480
export(float) var incorrect_time = 0.075
export(int) var length = 300
var offset

onready var right = $right
onready var left = $left
onready var tween = $Tween


func _ready():
	offset = length
#	offset = get_viewport_rect().size.x * 0.5
	modulate.a = 0
#	start()
	
func start(move_time:float, start:Vector2):
	global_position = start
	right.position = Vector2.RIGHT * offset
	left.position = Vector2.RIGHT * -offset
	var start1 = right.position
	var start2 = left.position
	
	tween.interpolate_property(right, "position", start1, Vector2.ZERO, 
	move_time, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.interpolate_property(left, "position", start2, Vector2.ZERO, 
	move_time, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.interpolate_method(self, "set_alpha", 0, 1.0, move_time * 0.5, 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_callback(self, move_time + incorrect_time,
	 "tween_callback")
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("finished")
	queue_free()
#	start()


func tween_callback():
#	right.position = Vector2.RIGHT * offset
#	left.position = Vector2.RIGHT * -offset
	modulate.a = 0


func set_alpha(a:float):
	modulate.a = a
