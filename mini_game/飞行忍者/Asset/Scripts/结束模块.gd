extends Control

onready var file_sys := $"文件读取模块"
onready var current_coin_text := $"当前金币"
onready var max_coin_text := $"最大金币"
onready var back_btn := $TextureButton

var main_scene_path = "res://Asset/Objects/主场景/主场景.tscn"

func _ready():
	back_btn.connect("button_down", self, "on_back_btn_down")
	file_sys.write(GlobalVals.score)
	show_results()
	
func show_results():
	current_coin_text.text = "当前金币：" + str(GlobalVals.score)
	max_coin_text.text = "最大记录：" + str(file_sys.high_score)

func on_back_btn_down():
	get_tree().change_scene(main_scene_path)
