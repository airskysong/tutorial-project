extends Node2D

signal pressed(card)

export(Resource) var card_match 

var id : int
var grade : int 
var card_name : String
var can_control :=  false

onready var sp = $Sprite

func init_card(_id:int, _grade:int, _card_name: String):
	id = _id
	grade = _grade
	card_name = _card_name
	var sprite_path = card_match.get_sprite(id)
	sp.texture = load(sprite_path)
	

func get_card_size():
	return sp.get_rect().size * sp.scale


func _input(event):
	if not can_control:
		return
	if event is InputEventScreenTouch and event.is_pressed():
		if sp.get_rect().has_point(to_local(event.position)):
			emit_signal("pressed", self)
			get_tree().set_input_as_handled()
	
