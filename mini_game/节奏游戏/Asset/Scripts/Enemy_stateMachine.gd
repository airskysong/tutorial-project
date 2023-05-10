extends "res://Asset/Scripts/StateMachine.gd"

var parent 

func _ready():
	parent = get_parent()
	add_state("idle")
	add_state("walk")
	add_state("attack")
	add_state("hit")
	add_state("dead")
	current = state.idle
	

func handle_state(_delta):
	match current:
		state.idle:
			parent.handle_idle()
			

func get_transition():
	match current:
		state.idle:
			pass
		state.walk:
			pass
		state.attack:
			pass
		state.hit:
			if not parent.anim.is_playing():
				if parent.on_death():
					return state.dead
				return state.idle
	return -1
	

func begin_transition():
	match current:
		state.attack:
			parent.handle_attack()
		state.hit:
			parent.handle_hit()
		state.dead:
			parent.handle_death()
