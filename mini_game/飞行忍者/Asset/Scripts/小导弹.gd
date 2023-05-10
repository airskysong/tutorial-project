extends Area2D

var detect_distance = 4*64
export(int)var move_speed = 1440
export(int)var steer_force = 500
var target : Area2D
var new_target:Vector2 = Vector2()
var velocity:Vector2 = Vector2()
var acc : Vector2 = Vector2()

func spawn(_target:Area2D, pos:Vector2):
	position = pos
	target = _target
	velocity = Vector2(-move_speed, 0)


func _process(delta):
	if not target:
		return
	new_target.x = target.position.x - 64
	new_target.y = target.position.y
	
	if (new_target - position).length_squared() <= pow(detect_distance, 2):
		chasse(delta)
	else:
		new_target = Vector2(-100, position.y)
		chasse(delta)
		if position.x < -60:
			queue_free()


func chasse(delta:float):
	var dir :Vector2 = (new_target - global_position).normalized() * move_speed
	var moment :Vector2 = (dir - velocity).normalized() * steer_force
	acc += moment
	velocity += acc * delta
	velocity = velocity.limit_length(move_speed)
	rotation = velocity.angle()
	position += velocity * delta
