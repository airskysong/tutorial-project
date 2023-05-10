extends Area2D
signal hurted(damage)

func get_hit(damage:int):
	emit_signal("hurted", damage)
