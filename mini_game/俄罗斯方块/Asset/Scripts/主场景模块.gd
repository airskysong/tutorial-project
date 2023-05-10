extends Node2D

export var move_cd : float = 0.3
export var fall_speed : float = 1
export var rotate_speed : float = .2

onready var grid_module = $"网格模块"
onready var move_timer = $"移动间隔"
onready var fall_timer = $"下落间隔"
onready var rotate_timer = $"旋转间隔"
onready var retry_btn := $"CanvasLayer/重来按钮"
onready var game_over_label := $"CanvasLayer/结束提示"
onready var score_label := $"CanvasLayer/分数文本"
onready var preview_pos := $"预览/预览位置"
onready var level_label := $"CanvasLayer/等级文本"

var tetris = [
	preload("res://Asset/Object/主场景模块/方块/I形.tscn"),
	preload("res://Asset/Object/主场景模块/方块/J形.tscn"),
	preload("res://Asset/Object/主场景模块/方块/O形.tscn"),
	preload("res://Asset/Object/主场景模块/方块/L形.tscn"),
	preload("res://Asset/Object/主场景模块/方块/S形.tscn"),
	preload("res://Asset/Object/主场景模块/方块/Z形.tscn"),
	preload("res://Asset/Object/主场景模块/方块/I形.tscn"),
	preload("res://Asset/Object/主场景模块/方块/T形.tscn")
	]


var screen_size :Vector2
var control_tetri : Node2D
var step : int 

var can_move : bool = true
var can_rotate : bool = true
var start_pos : Vector2
var score : int = 0

var next_tetri: Node2D
var tetri_offset : Vector2
var level : int = 1
var score_level = [
	2000,
	4000,
	6000,
	8000,
	10000,
	15000,
	20000,
	25000,
	30000,
	40000,
]

var test_level = [
	1000,
	2000,
	3000,
	4000,
	5000,
	6000,
]

func _ready(): 
	init()
	create_tetri()

func init():
	randomize()
	init_timer()
	init_grid_module()
	init_btn()
	set_game_over_ui(false)
	update_ui()

func init_timer():
	move_timer.connect("timeout", self, "on_move_timer_timeout")
	fall_timer.connect("timeout", self, "on_fall_timer_timerout")
	rotate_timer.connect("timeout", self, "on_rotate_timer_timerout")
	
	move_timer.wait_time = move_cd
	move_timer.start()
	fall_timer.wait_time = fall_speed
	fall_timer.start()
	rotate_timer.wait_time = rotate_speed
	rotate_timer.start()
	
func init_btn():
	retry_btn.connect("button_down", self,  "on_retry_btn_down")

func init_grid_module():
	screen_size = get_viewport_rect().size
	grid_module.position = screen_size / 2
	step = grid_module.step
	start_pos = grid_module.position + grid_module.get_start_pos_offset()
	

func create_tetri():
	if next_tetri:
		control_tetri = next_tetri
	else:
		control_tetri = get_one_tetri()
		
	control_tetri.position = start_pos 
	tetri_offset = grid_module.get_right_pos_offset(control_tetri)

	control_tetri.global_position += tetri_offset
	next_tetri = get_one_tetri()
	next_tetri.global_position = preview_pos.global_position 
	
	set_rand_color(control_tetri)
	set_rand_color(next_tetri)
	
	if not grid_module.is_valid_grid_pos(control_tetri):
		game_over()

func get_one_tetri():
	var index : int = int(rand_range(0, tetris.size()))
	var t = tetris[index].instance()
	add_child(t)
	t.scale =  float(grid_module.step) / 64   * Vector2.ONE
	return t

func _process(_delta):
	
	if can_move:
		move_timer.wait_time = move_cd
		
		if Input.is_action_pressed("ui_left"):
			move(Vector2.LEFT)
			wait_move()
		if Input.is_action_pressed("ui_right"):
			move(Vector2.RIGHT)
			wait_move()
		if Input.is_action_pressed("ui_down"):
			move_timer.wait_time = move_cd * 0.15
			move(Vector2.DOWN)
			wait_move()
	
	if can_rotate:
		if Input.is_action_pressed("ui_up"):
			rotate_tetri()
	

func wait_move():
		can_move = false
		move_timer.start()

func move(dir:Vector2):
	if not control_tetri:
		return
	control_tetri.position += dir * step

# 如果有子结点超出范围则回退位置，触底开始下一轮
	if not grid_module.is_valid_grid_pos(control_tetri):
		control_tetri.position -= dir * step
		if dir == Vector2.DOWN:
			to_next_turn()
		return
		
	grid_module.update_grids_datas(control_tetri)

func rotate_tetri():
	can_rotate = false
	rotate_timer.start()
	control_tetri.rotate(PI/2)
	
	control_tetri.global_position -= tetri_offset
	tetri_offset = Vector2(tetri_offset.y, tetri_offset.x)
	control_tetri.global_position += tetri_offset
	
	if not grid_module.is_valid_grid_pos(control_tetri):
		control_tetri.rotate(-PI/2)
		control_tetri.global_position -= tetri_offset
		tetri_offset = Vector2(tetri_offset.y, tetri_offset.x)
		control_tetri.global_position += tetri_offset
		return
	grid_module.update_grids_datas(control_tetri)


func to_next_turn():
	grid_module.update_grids_datas(control_tetri)
	var count = grid_module.check_row_full_and_delete()
	match count:
		1: score+=100
		2: score+=400
		3: score+=600
		4: score+=1000
	improve_difficulty()
	update_ui()
	create_tetri()


func game_over():
	set_game_over_ui(true)
	get_tree().paused = true


func set_game_over_ui(var flag : bool):
	retry_btn.visible = flag
	game_over_label.visible = flag

func on_retry_btn_down():
	get_tree().paused = false
	get_tree().reload_current_scene()


func on_move_timer_timeout():
	can_move = true

func on_fall_timer_timerout():
	move(Vector2.DOWN)
	can_move = true

func on_rotate_timer_timerout():
	can_rotate = true

func update_ui():
	score_label.text = "Score:" + str(score)
	level_label.text = "Level:" + str(level)

func set_rand_color(node : Node2D):
	var r : float = 0
	var g : float = 0
	var b : float = 0
	while r == g and g == b:
	 r = 0.5 if randf() <= 0.5 else 1
	 g = 0.5 if randf() <= 0.5 else 1
	 b = 0.5 if randf() <= 0.5 else 1
	node.modulate = Color(r, g, b, 1)

func improve_difficulty():
	if level >= score_level.size():
		return
	if score >= score_level[level - 1]:
		fall_timer.wait_time *= 0.85
		level += 1
