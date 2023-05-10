extends RigidBody2D

@export var move_speed = 100
@onready var anim = $AnimationPlayer


var dir = Vector2.ZERO

func _physics_process(_delta):
	if Input.get_action_strength("ui_up") > 0:
		dir = Vector2.UP
	elif Input.get_action_strength("ui_down") > 0:
		dir = Vector2.DOWN
	elif Input.get_action_strength("ui_left") > 0:
		dir = Vector2.LEFT
	elif Input.get_action_strength("ui_right") > 0:
		dir = Vector2.RIGHT
	else:
		dir = Vector2.ZERO


func _process(_delta):
	move_and_collide(dir * move_speed * _delta)
