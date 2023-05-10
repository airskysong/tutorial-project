extends KinematicBody2D
 
var move_speed = 150
export(int) var rotate_speed = 60

var velocity : Vector2 = Vector2()
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x / 2, screen_size.y)

func _physics_process(delta):
	position.y -= move_speed * delta
	rotation_degrees += rotate_speed * delta
	if position.y < -200:
		queue_free()
