extends KinematicBody2D
export(int) var accleration = 25
export(int) var move_speed = 80

var velocity : Vector2 = Vector2.ZERO
var friction : int = 80

var state: int
var input: Vector2 = Vector2()

onready var sp = $Sprite
onready var anim = $AnimationPlayer
onready var weapon = $Weapon
onready var talk_det = $talk_detector


func get_move_input():
	var x : int = 0
	var y : int = 0
	if Input.is_action_pressed("ui_right"):
		x += 1
	elif Input.is_action_pressed("ui_left"):
		x += -1
	elif Input.is_action_pressed("ui_down"):
		y += 1
	elif Input.is_action_pressed("ui_up"):
		y -= 1
	var motion : Vector2 = Vector2(x, y).normalized()
	input = motion


func get_attack_input():
	return Input.is_action_pressed("player_attack")


func handle_idle(delta:float):
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	anim.play("idle")
	move_and_collide(velocity)


func handle_walk(delta:float):
	velocity += input * accleration * delta
	velocity = velocity.limit_length(move_speed * delta)
	anim.play("walk")
	if input.x > 0:
		sp.flip_h = false
		weapon.scale = Vector2(1, 1)
	elif input.x < 0:
		sp.flip_h = true
		weapon.scale = Vector2(-1, 1)
	move_and_collide(velocity)


func handle_attack():
	anim.play("attack")

