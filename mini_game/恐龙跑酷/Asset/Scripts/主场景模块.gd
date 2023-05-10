extends Node2D

export(int) var cloud_move_speed = 16
export(int) var ground_move_speed = 640

onready var cloud_pbg := $"背景视差层"
onready var ground_pbg := $"地面背景层"
onready var max_label = $"CanvasLayer/MarginContainer/最高分"
onready var score_label = $"CanvasLayer/MarginContainer/分数"
onready var jump_label = $"CanvasLayer/MarginContainer/跳跃数"
onready var big = $"地面背景层/ParallaxLayer/大仙人掌"
onready var small = $"地面背景层/ParallaxLayer/小仙人掌"
onready var crow = $"地面背景层/ParallaxLayer/乌鸦"
onready var player = $"恐龙"
onready var game_over_tip = $"CanvasLayer/结束提示"
onready var restart_btn = $"CanvasLayer/重来按钮"
onready var file_sys = $"文件读取模块"


var jump_count = 0
var score : float = 0
var level = 1000

func _ready():
	restart_btn.connect("button_down", self, "on_restart_btn_down")
	player.connect("player_die", self, "on_game_over")
	
	game_over_tip.hide()
	restart_btn.hide()
	
	file_sys.read()
	update_high_score_ui(file_sys.high_score)
	set_node_visible(small, false)
	set_node_visible(crow, false)
	
func _process(delta):
	score += delta * 100
	score_label.text = "score " + str(int(score))
	if score >= level:
		if level == 1000:
			set_node_visible(small, true)
			level += 1000
		elif level == 2000:
			set_node_visible(crow, true)
			level += 1000
		
	scroll_pbg(delta)

func _input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		jump_count += 1
		jump_label.text = "jump " + str(jump_count)

func scroll_pbg(delta):
	cloud_pbg.scroll_offset.x -= cloud_move_speed * delta
	ground_pbg.scroll_offset.x -= ground_move_speed * delta 

func set_node_visible(node:Area2D, flag:bool):
	node.visible = flag
	node.set_deferred("monitorable", flag)
	node.set_deferred("monitoring", flag)

func on_game_over():
	file_sys.write(score)
	game_over_tip.show()
	restart_btn.show()
	get_tree().paused = true

func on_restart_btn_down():
	get_tree().paused = false	
	get_tree().reload_current_scene()

func update_high_score_ui(var _score):
	max_label.text = "highscore " + str(_score)
