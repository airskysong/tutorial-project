extends Resource

export(Array, String, FILE, "*.png") var paths

func get_sprite(id : int):
	if id >= 0 and id <= 55:
		return paths[id]
