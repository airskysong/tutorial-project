extends Node2D

var offset := Vector2.UP * 64
var duration = 0.5
var original_pos

onready var label := $Label
onready var tween = $Tween

var define_colors = [
	Color.red,
	Color.green,
	Color.orange
]

func _ready():
	hide()
	original_pos = position


func set_text(content:String, color_type:int):
	label.text = content
	modulate = define_colors[color_type]
	do_tween()

func do_tween():
	show()
	var to = original_pos + offset
	var color_to = modulate
	color_to.a = 0
	tween.interpolate_property(self, "position", 
	original_pos, to, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "modulate", modulate, color_to, 
	duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_callback(self, duration, "after_tween")
	tween.start()
	

func after_tween():
	modulate.a = 1
	global_position = original_pos
	hide()
