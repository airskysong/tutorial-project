extends Node2D


func _input(event):
	if event is InputEventKey or event is InputEventScreenTouch or event is InputEventMouseButton:
		start_game()
		
func start_game():
	get_tree().change_scene("res://Asset/Object/主场景模块/主场景模块.tscn")
