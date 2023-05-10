extends Area2D

export(String, FILE, "*tscn") var path
export(Vector2) var offset

func _ready():
	connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if body.name == "Player":
		to_next_level()

func to_next_level():
	if GlobalVal.player_spawn_point == Vector2.ZERO:
		GlobalVal.player_spawn_point = global_position + offset
	get_tree().change_scene(path)
	
