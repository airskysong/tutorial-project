extends Node2D

var coordinate : Vector2

var element_type : int = 0 setget set_type
var is_selecting : bool = false setget set_selecting

var element_sprite = [
	load("res://Asset/Resource/e1.png"),
	load("res://Asset/Resource/e2.png"),
	load("res://Asset/Resource/e3.png"),
	load("res://Asset/Resource/e4.png"),
	load("res://Asset/Resource/e5.png"),
	load("res://Asset/Resource/e6.png"),
	load("res://Asset/Resource/e7.png"),
]

onready var sp := $Sprite
onready var anim := $AnimationPlayer

func set_coordinate(pos:Vector2):
	coordinate = pos


func set_pos(pos:Vector2):
	position = pos


func set_type(var value):
	var last = value
	if value >= element_sprite.size():
		value = value % element_sprite.size()
	element_type = value
	sp.texture = element_sprite[element_type]
	
	
func set_size(size:float):
	scale = Vector2.ONE * size


func set_selecting(var value):
	is_selecting = value
	if is_selecting:
		sp.modulate.a = 0.5
	else:
		sp.modulate.a = 1


func destroy():
	anim.play("消除")
	yield(anim, "animation_finished")
	queue_free()
