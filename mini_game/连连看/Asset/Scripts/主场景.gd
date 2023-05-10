extends Node2D

var score :int = 0

onready var grid_manager = $"元素管理器"
onready var hub = $Hub

func _ready():
	score = 0
	grid_manager.connect("destroy_element", self, "on_element_destroy")
	grid_manager.connect("win", self, "on_win")
	hub.connect("game_over", self, "on_game_over")
	
	
func on_element_destroy(var _type):
	score = score + 100
	hub.update_score_ui(score)
	hub.add_time(1)


func on_win():
	get_tree().reload_current_scene()
	

func on_game_over():
	get_tree().reload_current_scene()
