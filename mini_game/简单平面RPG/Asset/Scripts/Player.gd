extends character

onready var sp = $Sprite


func _process(_delta):
	if move_dir.x < 0:
		sp.flip_h = true
	elif move_dir.x > 0:
		sp.flip_h = false


func get_input():
	move_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		move_dir += Vector2.UP 
	if Input.is_action_pressed("ui_down"):
		move_dir += Vector2.DOWN 
	if Input.is_action_pressed("ui_left"):
		move_dir += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		move_dir += Vector2.RIGHT
