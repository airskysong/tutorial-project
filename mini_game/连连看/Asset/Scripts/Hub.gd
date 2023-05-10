extends Control

signal game_over
export(float) var count_time = 5.0

var all_time
var interval = count_time / float(100)

onready var bar := $ProgressBar
onready var timer := $ProgressBar/Timer
onready var score_label := $Label

func _ready():
	timer.connect("timeout", self, "on_time_out")
	start()


func start():
	all_time = count_time
	timer.start(interval)


func on_time_out():
	all_time -= interval
	var value = all_time / float(count_time) * 100
	bar.value = value
	if all_time > 0:
		timer.start(interval)
	else:
		emit_signal("game_over")


func update_score_ui(score: int):
	score_label.text = "score:" + str(score)


func add_time(add:int):
	all_time += add
