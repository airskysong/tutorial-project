extends Node2D


onready var file_sys := $"文件读取模块"
onready var current_score_label := $"CanvasLayer/Control/当前分数文本"
onready var high_score_label := $"CanvasLayer/Control/最高分文本"
var main_scene = "res://Asset/Objects/主场景/主场景.tscn"

func _ready():
	file_sys.write(GlobalVal.score)
	current_score_label.text = "当前分数：" + str(GlobalVal.score)
	high_score_label.text = "最高分数：" + str(file_sys.high_score)


func _on_TextureButton_button_down():
	get_tree().change_scene(main_scene)
