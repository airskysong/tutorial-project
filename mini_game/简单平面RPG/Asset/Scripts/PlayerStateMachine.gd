extends FiniteStateMachine


func _ready():
	_add_state("idle")
	_add_state("run")
	_set_state(states.idle)
	
	
func _state_logic(delta:float):
	parent.get_input()
	parent.move(delta)

	
func _get_transition(_state:int):
	match _state:
		states.idle:
			if parent.velocity.length() > 10:
				return states.run
		states.run:
			if parent.velocity.length() <= 10:
				return states.idle
	return -1

func _begin_state():
#	._begin_state()
	match state:
		states.idle:
			anim.play("idle")
		states.run:
			anim.play("run")
	
func _after_state():
#	._after_state()
	pass
