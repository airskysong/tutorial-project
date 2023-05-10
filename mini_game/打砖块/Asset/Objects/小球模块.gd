extends KinematicBody2D

export(int) var move_speed = 600
var raw_speed = move_speed / 3
var acceleration_time = 2
var acceleration = move_speed / acceleration_time
var direction = Vector2()

var current_speed

signal game_over

func _ready():
	randomize()
	current_speed = move_speed

func start_pos(pos:Vector2, dir:Vector2):
	global_position = pos
	direction = dir.normalized()

func _physics_process(delta):
	current_speed = move_toward(current_speed, raw_speed, acceleration * delta)	
	var collision = move_and_collide(direction.normalized() 
	* current_speed * delta)
	if collision:
		if collision.collider.name == "横版模块":
			current_speed = move_speed
			var offset = global_position.x - collision.collider.global_position.x
			direction.x = offset/100
			direction.y = -1
			return
		elif collision.collider.has_method("hit"):
			collision.collider.call("hit")
		
		current_speed = move_speed
		direction = direction.bounce(collision.normal)
		
		var offset = rand_range(-PI/36, PI/36)
		direction = direction.rotated(offset)

func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("game_over")
