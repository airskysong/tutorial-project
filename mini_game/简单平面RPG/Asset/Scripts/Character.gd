extends KinematicBody2D
class_name character

export(int) var move_speed = 600
export(int) var acceleration = 100

var velocity : Vector2 = Vector2.ZERO
var move_dir : Vector2 = Vector2.ZERO

var friction = 0.15

func _physics_process(_delta):
	velocity = move_and_slide(velocity)
	velocity = lerp(velocity, Vector2.ZERO, friction)
	
func move(delta:float):
	move_dir = move_dir.normalized() * 10
	velocity += move_dir * delta * acceleration
	velocity = velocity.limit_length(move_speed)
	
	
