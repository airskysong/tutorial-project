extends KinematicBody2D

export(float) var rotate_speed = 2.0
export(int) var fall_speed = 150
export(int) var jump_force = 7000
export(float) var jump_interval = 0.8

onready var timer := $Timer
onready var sfx_explore = $"爆炸音效"
onready var sfx_get_coin = $"金币音效"
var velocity := Vector2()

var screen_size : Vector2 = Vector2()
signal game_over

func _ready():
	screen_size = get_viewport_rect().size
	scale = Vector2.ONE * 0.7
	timer.wait_time = jump_interval
	velocity += fall_speed * Vector2.DOWN

func _physics_process(delta):
	position.x = screen_size.x / 2
	rotation_degrees += 100 * delta
	velocity.y = fall_speed
	if Input.is_action_just_pressed("jump") and is_on_floor() and timer.time_left == 0:
		velocity.y = -jump_force
		timer.start()
	
	velocity = move_and_slide(velocity, Vector2.UP)



func _on_Area2D_area_entered(area):
	match area.name:
		"金币模块":
			GlobalVal.score += 100
			sfx_get_coin.play()
		"伤害区域":
			sfx_explore.play()
			on_damage()

func on_damage():
	emit_signal("game_over")
