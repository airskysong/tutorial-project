extends Node2D
signal player_die

var press = false
var pos = Vector2()
var move_speed = 500

var death:bool = false
onready var col = $Area2D/CollisionShape2D


func _process(delta):
	if press and not death:
		global_position = global_position.move_toward(pos, move_speed * delta)


func _input(event):
	if event is InputEventScreenTouch and event.is_pressed() or event is InputEventScreenDrag:
			pos = event.position
			press = true
	if event is InputEventScreenTouch and not event.is_pressed():
		press = false






