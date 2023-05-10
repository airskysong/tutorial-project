extends Node2D

var x : int
var y : int 
var element_type : int setget set_type
var is_selecting : bool = false setget set_select
var element_type_sprite = [
	preload("res://Assets/Resource/e1.png"),
	preload("res://Assets/Resource/e2.png"),
	preload("res://Assets/Resource/e3.png"),
	preload("res://Assets/Resource/e5.png"),
	preload("res://Assets/Resource/e6.png"),
	preload("res://Assets/Resource/e7.png"),
	preload("res://Assets/Resource/e4.png"),
]

onready var sp := $Sprite
onready var anim := $AnimationPlayer
#onready var timer := $Timer

func _ready():
	randomize()
	var size = element_type_sprite.size()
	self.element_type = int(rand_range(0, size))

func update_x_and_y(_x:int, _y:int):
	x = _x
	y = _y

func update_datas(_x:int, _y:int, pos:Vector2):
	x = _x
	y = _y
	global_position = pos
	anim.play("生成")
	yield(anim,"animation_finished")
	anim.play("RESET")

func set_select(value:bool):
	is_selecting = value
	if is_selecting:
		anim.play("选择效果")
	else:
		anim.play("RESET")
		
func set_type(value: int):
	element_type = value
	sp.texture = element_type_sprite[value]

func dispose():
	anim.play("消失")
	yield(anim, "animation_finished")
	call_deferred("queue_free")

func set_anim_speed(var multiplus):
	anim.playback_speed = multiplus

func set_forcus():
	anim.play("选择效果3")

func set_all_forcus():
	anim.play("选择效果2")
