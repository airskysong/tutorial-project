extends StaticBody2D

onready var sp := $Sprite

var per_score = 100

signal break_block(pos)

func add_score():
	GlobalVal.temp_score += per_score

func hit():
	add_score()
	emit_signal("break_block", global_position)
	queue_free()

func set_color(color:Color):
	sp.modulate = color
	
