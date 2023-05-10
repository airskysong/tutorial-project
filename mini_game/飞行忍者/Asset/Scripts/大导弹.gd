extends Area2D

var move_speed = 1440

func _ready():
	position.x = get_viewport_rect().size.x

func _process(_delta):
	position.x -= move_speed * _delta
