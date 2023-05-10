extends Node2D

func _ready():
	load_spawn_point()

func load_spawn_point():
	if GlobalVal.player_spawn_point != Vector2.ZERO:
		$YSort/Player.global_position = GlobalVal.player_spawn_point

