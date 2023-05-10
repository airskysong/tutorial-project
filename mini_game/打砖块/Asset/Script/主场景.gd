extends Node2D

export(PackedScene) var bracket_model
export(float) var bracket_move_speed = 200.0
export(PackedScene) var block_model 
export(PackedScene) var ball_model
export(PackedScene) var vfx_explore 

onready var b_color = $"背景色板"
onready var level = $"CanvasLayer/Control/MarginContainer/关卡文本"
onready var score = $"CanvasLayer/Control/MarginContainer/分数文本"
onready var cam = $"Camera2D"
onready var joystick = $"摇杆"

var wall_size = 10
var bracket
var block
var ball

var block_size
var screen_size
var bracket_size
var base_block_nums = 2
var block_count = 0
var explore

var begin:bool = false

func _ready():
	joystick.hide()
	
	bracket = bracket_model.instance() as StaticBody2D
	block = block_model.instance() as StaticBody2D
	ball = ball_model.instance()
	
	screen_size = get_viewport_rect().size
	bracket_size = get_node_size(bracket)
	block_size = get_node_size(block)
	
	add_child(bracket)
	add_child(ball)
	
	ball.connect("game_over", self, "on_game_over")
	create_blocks(
		base_block_nums + GlobalVal.level,
		base_block_nums + GlobalVal.level)

	bracket.global_position = Vector2(screen_size.x/2, screen_size.y 
	- bracket_size.y)

	update_ui()
	b_color.color = get_rand_color()
	
	explore = vfx_explore.instance()
	add_child(explore)
#	explore.hide()
#给场景添加方块 
func create_blocks(row:int, column:int):
	var start_point = Vector2(screen_size.x/2 - block_size.x*(row-1)/2,
	2 * block_size.y)
	
	for y in range(column):
		var new_color = get_rand_color()
		for x in range(row):
			var b = block_model.instance()
			add_child(b)
			#设置随机颜色
			b.set_color(new_color)
			# 设置排布的位置
			b.global_position = Vector2(start_point.x + x * block_size.x, 
			start_point.y + y * block_size.y)
			b.connect("break_block", self, "on_block_break")
			block_count += 1

func _physics_process(delta):
	if Input.is_action_pressed("ui_left") or joystick.get_joystick_pos().x<0:
		move_bracket(Vector2.LEFT * bracket_move_speed * delta)
	elif Input.is_action_pressed("ui_right") or joystick.get_joystick_pos().x>0:
		move_bracket(Vector2.RIGHT * bracket_move_speed * delta)


func _input(event):
	if not begin:
		begin = true
		ball.start_pos(bracket.global_position + Vector2.UP * 64, Vector2.UP)
	
	if event is InputEventScreenTouch and event.is_pressed():
		if not joystick.visible:
			joystick.show()
			joystick.global_position = event.position
	if event is InputEventScreenTouch and not event.is_pressed():
		joystick.hide()

func move_bracket(move:Vector2):
	if bracket:
		bracket.global_position += move
		bracket.position.x = clamp(bracket.position.x, wall_size
		+ bracket_size.x / 2, -wall_size +  
		screen_size.x - bracket_size.x/2)
	
func get_node_size(node:Node):
	var result = Vector2()
	result = node.get_node("Sprite").get_rect().size * node.scale
	return result

func on_game_over():
	GlobalVal.temp_score = 0
	get_tree().reload_current_scene()

func on_block_break(_pos:Vector2):
	block_count-=1
	play_vfx(_pos)
	update_ui()
	if block_count == 0:
		go_next_level()

#播放特效
func play_vfx(pos:Vector2):
	explore.global_position = pos
	explore.restart()
	shake()
	
#获取一种随机颜色
func get_rand_color():
	var r = rand_range(.5, 1)
	var g = rand_range(.5, 1) * r
	var blue = rand_range(.5, 1) * g
	var new_color = Color(r, g, blue)
	return new_color

func go_next_level():
	GlobalVal.level += 1
	GlobalVal.score += GlobalVal.temp_score
	GlobalVal.temp_score = 0
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().paused = true
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().paused = false
	get_tree().reload_current_scene()

func update_ui():
	level.text = "关卡:" + str(GlobalVal.level + 1)
	score.text = "分数:" + str(GlobalVal.score + GlobalVal.temp_score)

#func shake_screen():
#	cam.shake_screen(32, 0.5)
	
func shake():
	cam.shake_screen(8, 0.3)
