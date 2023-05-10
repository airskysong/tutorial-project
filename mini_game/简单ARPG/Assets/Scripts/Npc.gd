extends KinematicBody2D

export(int) var patrol_offset = 128
export(Vector2) var patrol_dir = Vector2.LEFT
export(int) var move_speed = 80

var patrol_pos = []
var current_patrol
var acc = 15
var velocity : Vector2 = Vector2()
var friction : int = 80
var can_interactable = false

onready var sp = $Sprite
onready var anim = $AnimationPlayer
onready var dialog = $DialogPlayer


func _ready():
	patrol_pos.append(global_position - patrol_offset * patrol_dir)
	patrol_pos.append(global_position + patrol_offset * patrol_dir)
	current_patrol = patrol_pos[1]


func handle_patrol(delta:float):
	if global_position.distance_squared_to(current_patrol)<=pow(10, 2):
		current_patrol = patrol_pos[0] if current_patrol == patrol_pos[1] else patrol_pos[1]
	move_to(current_patrol, delta)


func handle_idle(delta:float):
	velocity = velocity.move_toward(Vector2.ZERO, delta * friction)
	anim.play("idle")
	move_and_collide(velocity)

	
func move_to(to:Vector2, delta:float):
	var dir = (to - global_position).normalized()
	velocity += dir * acc * delta
	velocity = velocity.limit_length(delta * move_speed)
	if dir.x > 0:
		sp.flip_h = false
	elif dir.x < 0:
		sp.flip_h = true
	anim.play("walk")
	move_and_collide(velocity)

func _unhandled_input(event):
	if can_interactable and event.is_action_pressed("interact"):
		dialog.show_dialog()


func _on_interactable_area_exited(_area):
	can_interactable = false


func _on_interactable_area_entered(_area):
	can_interactable = true
