extends Node2D
class_name FiniteStateMachine

var states = {}
var state : int = -1 setget _set_state
var previour_state : int

onready var parent = get_parent()
onready var anim = parent.get_node_or_null("AnimationPlayer")


func _add_state(new_state:String):
	states[new_state] = states.size()


func _physics_process(delta):
	if state != -1:
		_state_logic(delta)
		var transition = _get_transition(state)	
		if transition != -1:
			_set_state(transition)


func _state_logic(_delta : float):
	pass	


func _begin_state():
	print("begin")
	pass

	
func _after_state():
	print("after")
	pass


func _get_transition(_transition : int):
	return -1
	

func _set_state(new_state: int):
	previour_state = state
	_after_state()
	state = new_state
	_begin_state()
	
