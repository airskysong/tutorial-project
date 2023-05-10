extends Node2D

signal clicked(card)

var card_type setget set_card_type
var can_selecting :bool 
var is_front:bool setget set_front

var card_sprite = [
	load("res://Asset/Resource/e1.png"),
	load("res://Asset/Resource/e2.png"),
	load("res://Asset/Resource/e3.png"),
	load("res://Asset/Resource/e4.png"),
	load("res://Asset/Resource/e5.png"),
	load("res://Asset/Resource/e6.png"),
]

onready var back := $Back
onready var front := $Front
onready var Icon := $Front/Icon


func _ready():
	self.is_front = false
	can_selecting = true


func init(var pos, var _card_type):
	self.card_type = _card_type
	position = pos


func set_card_type(var value):
	if not value in range(card_sprite.size()):
		value = 0
	card_type = value
	Icon.texture = card_sprite[value]




func _input(event):
	if not can_selecting:
		return
	if event is InputEventScreenTouch and event.is_pressed():
		var rect = back.get_rect()
		if rect.has_point(to_local(event.position)):
			_click()


#func get_card_types_size():
#	return card_sprite.size()

func set_front(value:bool):
	is_front = value
	if is_front:
		front.show()
		back.hide()
	else:
		front.hide()
		back.show()
	return is_front

func _click():
	emit_signal("clicked", self)
	
