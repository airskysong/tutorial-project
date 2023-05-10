extends KinematicBody2D

signal hit

export(int)var base_distance = 64
export(int)var base_attack = 10

var can_move := true
var move_duration = 0.6

onready var tween = $Tween
onready var anim = $AnimationPlayer
onready var sp = $Sprite
onready var state_m = $PlayerStateMachine
onready var weapon = $weapon
onready var raycast = $RayCast2D
onready var hitbox = $weapon/Area2D

var state
var motion := Vector2.ZERO
var rhythm_player
var invalid_hit = false

func _ready():
	hitbox.damage = base_attack
	rhythm_player = get_node_or_null("RhythmPlayer")
	if rhythm_player:
		rhythm_player.connect("beat", self, "on_beat")
	state = state_m.state

#
func _input(event):
	if can_move and event.is_action_pressed("attack"):
		if not anim.current_animation == "attack":
			emit_signal("hit")
			if invalid_hit:
				state_m.set_state(state_m.state.attack)


func get_move_input():
	var input = Vector2()
	if Input.is_action_pressed("ui_up"):
		input = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		input = Vector2.DOWN
	elif Input.is_action_pressed("ui_left"):
		input = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		input = Vector2.RIGHT
	
	if input!=Vector2.ZERO:
		emit_signal("hit")
		if can_move:
			turn(input)
			if invalid_hit:
				motion = input
				return true
	return false


func move_to(dir:Vector2):
	if not check_dir(dir):
		do_tween_step_move(dir)


func do_tween_step_move(dir:Vector2):
	var to = global_position + dir * base_distance
	tween.interpolate_property(self, "global_position", global_position, 
	to, move_duration, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	can_move = true


func on_beat(flag):
	invalid_hit = flag	


func check_dir(dir:Vector2):
	raycast.cast_to = dir * base_distance
	raycast.force_raycast_update()
	var check = raycast.is_colliding()
	return check


func handle_walk():
	anim.play("walk")
	move_to(motion)


func handle_idle():
	anim.play("idle")


func handle_attack():
	anim.play("attack")


func turn(dir:Vector2):
	if dir.x > 0:
		sp.flip_h = false
		weapon.scale = Vector2(1, 1)
	elif dir.x < 0:
		sp.flip_h = true
		weapon.scale = Vector2(-1, 1)
