extends Control


func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey:
		start_game()

func start_game():
	SceneTransition.change_and_translate_scene("res://Asset/Objects/主场景/主场景.tscn")
