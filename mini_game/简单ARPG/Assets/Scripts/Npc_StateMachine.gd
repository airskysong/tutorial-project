extends "res://Assets/Scripts/StateMachine.gd"

var anim : AnimationPlayer
var parent

var is_talking = false

func _ready():
	parent = get_parent()
	add_state("idle")
	add_state("patrol")
	current = state.patrol


func update_state(delta:float):
	match current:
		state.idle:
			parent.handle_idle(delta)
		state.patrol:
			parent.handle_patrol(delta)


func get_transition():
	match current:
		state.idle:
			if not is_talking:
				return state.patrol
		state.patrol:
			if is_talking:
				return state.idle
	return -1

