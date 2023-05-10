extends Node2D

onready var center: = $Sprite/Center
var dragging = -1
var radius 

func _ready():
	radius = $Sprite.get_rect().size.x / 2

func _input(event):
	if (event is InputEventScreenTouch and event.is_pressed()) or event is InputEventScreenDrag:
		var distance = (event.position - global_position).length()
		if distance <= radius or event.index == dragging:
			dragging = event.index
			center.set_global_position(event.position)
		
			if distance > radius:
				var dir = center.position.normalized()
				center.set_position(dir * radius)
#
	if event is InputEventScreenTouch and not event.is_pressed():
		if event.index == dragging:
			dragging = -1
			$Tween.interpolate_property(center, "position", center.position, Vector2.ZERO, 0.3,Tween.TRANS_SINE,Tween.EASE_IN)
			$Tween.start()
			
func get_joystick_pos():
	return center.position.normalized()
