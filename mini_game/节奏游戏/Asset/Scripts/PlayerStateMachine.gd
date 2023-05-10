extends "res://Asset/Scripts/StateMachine.gd"

var parent : KinematicBody2D

func _ready():
	parent = get_parent()
	add_state("idle")
	add_state("walk")
	add_state("attack")
	current = state.idle

func handle_state(_delta):
	match current:
		state.idle:
			parent.handle_idle()


func get_transition():
	match current:
		state.idle:
				if parent.get_move_input():
					return state.walk
		state.walk:
				if not parent.anim.is_playing():
					parent.can_move = true
					return state.idle
		state.attack:
			if not parent.anim.is_playing():
				parent.can_move = true
				return state.idle
	return -1


func begin_transition():
	match current:
		state.attack:
			parent.handle_attack()
		state.walk:
			parent.handle_walk()
			parent.can_move = false



