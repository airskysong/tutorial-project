extends Node2D

@onready var btn_start = $"Control/背景图/VBoxContainer/开始按钮"
@onready var btn_exit = $"Control/背景图/VBoxContainer/结束按钮"


# Called when the node enters the scene tree for the first time.
func _ready():
	btn_start.button_down.connect(self.on_btn_start_down)
	btn_exit.button_down.connect(self.on_btn_exit_down)

func on_btn_start_down():
	get_tree().change_scene_to_file("res://Asset/Scenes/main_scene.tscn")
	
func on_btn_exit_down():
	get_tree().quit()
