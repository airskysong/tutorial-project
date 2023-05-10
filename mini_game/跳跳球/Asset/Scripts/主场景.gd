extends Node2D

export(float) var interval = 5
export(PackedScene) var ball_model
export(int) var speed = 60


var end_scene = "res://Asset/Objects/结束/结束模块.tscn"

onready var timer = $Timer


var rings = [
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块.tscn"),
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块2.tscn"),
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块3.tscn"),
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块4.tscn"),
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块5.tscn"),
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块6.tscn"),
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块7.tscn"),
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块8.tscn"),
	preload("res://Asset/Objects/主场景/圆圈模块/圆圈模块9.tscn"),
]


func _ready():
	GlobalVal.score = 0
	randomize()
	timer.wait_time = interval
	timer.start()
	timer.connect("timeout", self, "on_timer_time_out")
	create_ring()
	create_ball()
	
	
func on_timer_time_out():
	create_ring()
	timer.start()
	
func create_ring():
	var rand_index := int(rand_range(0, rings.size()))
	var b = rings[rand_index].instance()
	b.move_speed = speed
	add_child(b)
	
func create_ball():
	var p = ball_model.instance()
	p.connect("game_over", self, "on_game_over")
	p.fall_speed = speed
	add_child(p)

func on_game_over():
	go_end_scene()

func go_end_scene():
	get_tree().change_scene(end_scene)
