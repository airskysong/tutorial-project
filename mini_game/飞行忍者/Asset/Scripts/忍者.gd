extends Area2D

var press = false
var pos = Vector2()

onready var sfx_death := $SFX_death
onready var vfx_hurt := $VFX_hurt
onready var col = $CollisionShape2D

signal player_die
var death:bool = false

func _process(delta):
	if press and not death:
		global_position = global_position.move_toward(pos, 1000 * delta)

func _input(event):
	if event is InputEventScreenTouch and event.is_pressed() or event is InputEventScreenDrag:
			pos = event.position
			press = true
	if event is InputEventScreenTouch and not event.is_pressed():
		press = false


func _on__area_entered(area):
	if area.collision_layer==2:
		hit()
		
func hit():
	emit_signal("player_die")
	col.set_deferred("disable", true)
	death = true
	sfx_death.play()
	vfx_hurt.restart()



