extends Node2D

export(int) var one_wave_time = 10

var player_model = preload("res://Asset/Object/主场景/炸弹人模块.tscn")
var enemy_model = preload("res://Asset/Object/主场景/敌方模块.tscn")
var bomb_model = preload("res://Asset/Object/主场景/炸弹模块.tscn")

var player
var screen_size
var enemies_base = 5

onready var timer = $Timer
onready var path = $Path2D/PathFollow2D
onready var tip = $"CanvasLayer/提示"

func _ready():
	GlobalVal.score = 0
	GlobalVal.wave = 0
	randomize()
#	timer.wait_time = 3
	timer.wait_time = one_wave_time
	timer.start()
	screen_size = get_viewport_rect().size
	player = create_player()
	player.connect("player_die", self, "on_game_over")
	start_wave()


func create_player():
	var p = player_model.instance()
	add_child(p)
	p.position = screen_size / 2 
	return p

func create_enemie(pos:Vector2):
	var e = enemy_model.instance()
	add_child(e)
	e.spawn(pos, player)


func _on_Timer_timeout():
	start_wave()

func start_wave():
	GlobalVal.wave += 1
	var content : String = "第%s波敌人即将到来..."%str(GlobalVal.wave)
	yield(tip.show_tip(content), "completed")
	var enemy_num = int(rand_range(enemies_base, 
	enemies_base * 2 + 1))
	for _c in range(enemy_num):
		path.unit_offset = rand_range(0, 1)
		var pos = path.position		
		create_enemie(pos)
	add_level()

func add_level():
	enemies_base += GlobalVal.wave
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		e.move_speed += GlobalVal.wave * 8		

func on_game_over():
#	get_tree().reload_current_scene()
	ScreenTransition.change_and_translate_scene("res://Asset/Object/结束/结束模块.tscn")
