extends KinematicBody2D

export(int)var move_speed = 80
export(int)var acc = 15

var health : int = 2
var patrol_distance : int = 264
var patrol_dir : Vector2 = Vector2.LEFT
var friction = 80

var state : int = patrol
var velocity := Vector2()

var original_pos : Vector2
var target_pos : Vector2
var patrol_offset = patrol_distance * patrol_dir
var player

enum {
	patrol,
	chasse,
	hit,
	dead
}

onready var detector = $Detector
onready var timer = $Detector/Timer
onready var anim := $AnimationPlayer
onready var sp := $Sprite


func _ready():
	original_pos = global_position
	target_pos = original_pos + patrol_offset
	timer.start(0.2)
	timer.connect("timeout", self, "begin_detect")


func _physics_process(delta):
	handle_state(delta)


func handle_state(delta):
	match state:
		patrol:
			begin_patrol(delta)
		chasse:
			begin_chasse(delta)
		hit:
			velocity = velocity.move_toward(Vector2.ZERO, delta * friction)
		dead:
			velocity = velocity.move_toward(Vector2.ZERO, delta * friction)
	
	move_and_collide(velocity)
	var transition = get_transition()
	if transition != -1:
		state = transition

func get_transition():
	match state:
		patrol:
			if player!=null:
				return chasse
		chasse:
			if player == null:
				target_pos = original_pos
				return patrol
		hit:
			if not anim.is_playing():
				return patrol
	
	return -1


func begin_patrol(delta):
	move_to(target_pos, delta)
	if global_position.distance_squared_to(target_pos) <= pow(10, 2):
		patrol_offset = -patrol_offset
		target_pos = original_pos + patrol_offset


func begin_chasse(delta):
	if player:
		var target = player.global_position
		move_to(player.global_position, delta)
		if global_position.distance_squared_to(target)>=pow(146, 2):
			player = null


func move_to(to:Vector2, delta:float):
	var dir = (to - global_position).normalized()
	velocity += dir * acc * delta
	velocity = velocity.limit_length(delta * move_speed)
	if dir.x > 0:
		sp.flip_h = false
	elif dir.x < 0:
		sp.flip_h = true
	anim.play("walk")

	
func begin_detect():
	var bodies : Array = detector.get_overlapping_bodies()
	if bodies.size() > 0 and bodies[0].name == "Player":
		player = bodies[0]
		return true
	return false


func knock_back():
	var dir = 1 if sp.flip_h else -1
	velocity = Vector2(15, 0) * dir
	velocity = velocity.limit_length(80)


func take_hit(damage:int):
	if anim.current_animation == "hurt":
		return
	health -= damage
	if health <= 0:
		take_dead()
		state = dead
		return
	state = hit
	anim.play("hurt")
	knock_back()
	

func take_dead():
	anim.play("dead")
	yield(anim,"animation_finished")
	queue_free()
