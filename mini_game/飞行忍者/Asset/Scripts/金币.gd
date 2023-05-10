extends Area2D

var move_speed :int = 300
onready var col := $CollisionShape2D
onready var sfx_coin := $SFX_coin


func spawn_coins(pos, speed):
	position = pos
	move_speed = speed


func _process(delta):
	position += Vector2.LEFT * move_speed * delta

func _on__area_entered(_area):
	on_destory()

func get_size():
	return $CollisionShape2D.shape.extents*2

func on_destory():
	col.set_deferred("disabled", true)
	col.hide()
	sfx_coin.play()
	yield(sfx_coin,"finished")
	GlobalVals.score += 100
	queue_free()
