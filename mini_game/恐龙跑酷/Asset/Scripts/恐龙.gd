extends KinematicBody2D

export(int)var jump_force : int = 500
export(int)var gravity : int = 1500

onready var anim := $AnimationPlayer
onready var sfx_jump := $"声效跳跃"

var jump
var press_jump : bool = false
var can_jump : bool = false
var velocity : Vector2 

signal player_die

func _ready():
	jump = InputEventAction.new()
	jump.action = "jump"
	anim.play("奔跑")
	
func _physics_process(delta):
	if Input.is_action_pressed("jump") and can_jump:
		sfx_jump.play()
		velocity.y = -jump_force
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	can_jump = is_on_floor()
	
func _input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		jump.pressed = true
		Input.parse_input_event(jump)
	if event is InputEventScreenTouch and not event.is_pressed():
		jump.pressed = false
		Input.parse_input_event(jump)

func _on__area_entered(area):
	area.queue_free()
	anim.play("受伤")
#	get_tree().paused = true
#	yield(anim, "animation_finished")
#	get_tree().paused = false
	emit_signal("player_die")	
