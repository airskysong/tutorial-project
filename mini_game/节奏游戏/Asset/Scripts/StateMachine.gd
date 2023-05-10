extends Node2D

var state = {}
var current : int

func _physics_process(_delta):
	handle_state(_delta)
	var t = get_transition()
	if t != -1:
		current = t
		begin_transition()
		
func handle_state(_delta):
	pass
	
func get_transition():
	return -1

func begin_transition():
	pass

func add_state(new_state: String):
	state[new_state] = state.size()
	
func set_state(new_state:int):
	current = new_state
	begin_transition()
