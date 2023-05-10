extends Node2D

export(int)var max_health = 100

var grid_size = 64
var move_duraion = 0.3
var current_health = 100 setget update_ui

onready var sp = $Sprite
onready var tween = $Tween
onready var anim = $AnimationPlayer
onready var hurt_box = $HurtBox
onready var state_m = $Enemy_stateMachine
onready var health_p = $HealthBar/Health_progress
onready var health_tween = $HealthBar/Tween

func _ready():
	connect_hurt_box()
	self.current_health = 100

func connect_hurt_box():
	if hurt_box:
		hurt_box.connect("hurted", self, "get_hit")


func handle_idle():
	anim.play("idle")


func handle_walk():
	anim.play("walk")
	

func handle_hit():
	anim.play("hit")
	

func handle_attack():
	anim.play("attack")


func get_hit(_damage):
	if anim.current_animation != "hit":
		self.current_health -= _damage
		state_m.set_state(state_m.state.hit)


func handle_death():
	queue_free()


func on_death():
	if current_health <= 0:
		return true
	return false


func update_ui(value):
	var to = int(clamp(value, 0, 100))
	do_tween_health(current_health, to)
	current_health = value

	
	
func do_tween_health(from:float, to:float):
	health_tween.interpolate_property(health_p,"value", from, to, 0.85,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	health_tween.start()
	
