extends Area2D

onready var timer:= $Timer
onready var sp := $Sprite
onready var bomb_model := preload("res://Asset/Object/主场景/炸弹模块.tscn")
onready var vfx_explore := $VFX_explore
onready var sfx_die := $SFX_die
onready var anim := $AnimationPlayer


var move_speed: int = 320

var spawn_bomb_timer = 1
var spawn_bomb_extra_timer = 2

var start_touch : bool = false
var target_pos : Vector2 = Vector2()
var velocity : Vector2 = Vector2()
var screen_size
var running = false
signal player_die

func _ready():
	randomize()
	screen_size = get_viewport_rect().size
	timer.wait_time = spawn_bomb_timer
	timer.start()
	anim.play("静止")
	
func _process(delta):
	if not start_touch:
		anim.play("静止")
		running = false
		return
	velocity = (target_pos - position).normalized() * move_speed
	position += velocity * delta
	position = limit_screen_size(position)
	set_direction(velocity)
	if not running:
		running = true
		anim.play("行走")
		
func _input(event):
	if event is InputEventScreenTouch and event.is_pressed() or event is InputEventScreenDrag:
		start_touch = true
		target_pos = event.position
	if event is InputEventScreenTouch and not event.is_pressed():
		start_touch = false

func hit():
	emit_signal("player_die")
	call_deferred("set_process", false)
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
#	monitorable = false
#	monitoring = false
	vfx_explore.restart()
	sfx_die.play()

func _on_Timer_timeout():
	spawn_bomb_extra_timer = rand_range(0, 2)
	timer.wait_time = spawn_bomb_timer + spawn_bomb_extra_timer
	spawn_bomb()

func spawn_bomb():
	var b = bomb_model.instance()
	get_parent().add_child(b)
	b.spawn(position)
	
func limit_screen_size(pos:Vector2):
	var offset = 20
	pos.x = clamp(pos.x, offset, screen_size.x - offset)
	pos.y = clamp(pos.y, offset, screen_size.y - offset)
	return pos

func set_direction(face:Vector2):
	if face.x < 0:
		sp.flip_h = true
	elif face.x > 0:
		sp.flip_h = false

