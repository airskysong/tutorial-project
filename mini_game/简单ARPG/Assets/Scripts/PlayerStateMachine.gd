extends "res://Assets/Scripts/StateMachine.gd"

var parent

func _ready():
	parent = get_parent()
	add_state("idle")
	add_state("walk")
	add_state("attack")
	add_state("talk")
	current = state.idle


func update_state(delta):
	match current:
		state.idle:
			parent.get_move_input()
			parent.handle_idle(delta)
		state.walk:
			parent.get_move_input()
			parent.handle_walk(delta)


func get_transition():
	match current:
		state.idle:
			if parent.get_attack_input():
				return state.attack
			if parent.input!=Vector2.ZERO:
				return state.walk
		state.walk:
			if parent.get_attack_input():
				return state.attack
			if parent.input == Vector2.ZERO:
				return state.idle
		state.attack:
			if not parent.anim.is_playing():
				return state.idle
	return -1


func before_transition(_current_state:int):
	match _current_state:
		state.attack:
			parent.handle_attack()

