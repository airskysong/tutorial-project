extends Control


func _input(event):
	if event is InputEventKey or event is InputEventScreenTouch or event is InputEventMouseButton:
		start_game()
		
func start_game():
	ScreenTransition.change_and_translate_scene("res://Asset/Object/主场景/主场景.tscn")
