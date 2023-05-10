extends Node
class_name state_machine

var current:int 
var state = {}


func _physics_process(delta):
	update_state(delta)
	var transition = get_transition()
	if transition != -1:
		after_transiton(current)
		current = transition
		before_transition(current)

func update_state(_delta:float):
	pass
	
func handle_state():
	pass

func get_transition():
	return -1

func add_state(state_name:String):
	state[state_name] = state.size()

func before_transition(_current_state:int):
	pass

func after_transiton(_last_state:int):
	pass
