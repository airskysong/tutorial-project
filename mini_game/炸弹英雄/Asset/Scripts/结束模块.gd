extends Control

onready var score := $"记录1"
onready var max_score := $"记录2"
onready var restart_btn := $"重来按钮"
onready var file_sys := $"文件读写模块"


func _ready():
	restart_btn.connect("button_down", self, "on_restart_btn_down")
	show_result()
	
	
func on_restart_btn_down():
	ScreenTransition.change_and_translate_scene("res://Asset/Object/主场景/主场景.tscn")
	
func show_result():
	var current_score = GlobalVal.score
	file_sys.write(current_score)
	var record_score = file_sys.high_score
	score.text = "消灭了%s个敌人"%str(current_score)
	max_score.text = "最大记录:%s"%str(record_score)
