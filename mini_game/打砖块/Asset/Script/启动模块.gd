extends Node2D

export(PackedScene) var next_scene

func _ready():
	yield(get_tree().create_timer(3),"timeout")
	get_tree().change_scene_to(next_scene)
		
