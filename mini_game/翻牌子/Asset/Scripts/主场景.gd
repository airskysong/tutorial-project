extends Node2D

var time = 0
var turn = 0


onready var time_ui = $CanvasLayer/time
onready var turn_ui = $CanvasLayer/turn
onready var timer = $CanvasLayer/time/Timer
onready var card_manager = $"卡牌管理器"



func _ready():
	timer.start()
	update_ui()
	card_manager.connect("one_turn", self, "on_one_turn")

func update_ui():
	time_ui.text = "time:" + str(time)
	turn_ui.text = "turn:" + str(turn)

func _on_Timer_timeout():
	time += 1
	update_ui()

func on_one_turn():
	turn += 1
	update_ui()
