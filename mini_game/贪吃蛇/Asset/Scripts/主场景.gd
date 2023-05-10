extends Node2D

onready var player = $"贪吃蛇"

onready var food_pref = preload("res://Asset/Object/主场景/食物.tscn")
onready var score_l = $"CanvasLayer/hub/MarginContainer/当前分数"
onready var highscore_l = $"CanvasLayer/hub/MarginContainer/最大分数"

var screen_size : Vector2
var high_score : int
var level: int = 100

func _ready():
	init()
	create_food()
	update_ui()

func init():
	randomize()
	screen_size = get_viewport_rect().size
	player.connect("player_fail", self, "on_game_over")


func create_food():
	var food = food_pref.instance()
	call_deferred("add_child", food)
	food.connect("tree_exited", self, "on_add_score")
	food.position = get_random_pos()
	
func get_random_pos():
	var offset : Vector2 = Vector2.ONE * 64 * 3
	var rand_x = rand_range(offset.x, screen_size.x - offset.x)
	var rand_y = rand_range(offset.y, screen_size.y - offset.y)
	return Vector2(rand_x, rand_y)

func on_game_over():
	GlobalVal.record_score()
	get_tree().reload_current_scene()

func update_ui():
	highscore_l.text = "最高分:" + str(GlobalVal.high_score)
	score_l.text = "分数:" + str(GlobalVal.score)

func on_add_score():
	GlobalVal.score += 100
	improve_the_difficulty()
	update_ui()
	create_food()

func improve_the_difficulty():
	if GlobalVal.score >= level:
		level += 300
		player.step_time -= 0.05
