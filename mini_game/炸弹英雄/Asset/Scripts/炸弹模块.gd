extends Node2D

export var wait_time:float = 3.0

onready var col = $Area2D/CollisionShape2D
onready var timer = $Timer
onready var anim = $AnimatedSprite
onready var sfx_explore = $SFX_explore
onready var count_down = $"倒计时"

var cam : Camera2D

func spawn(pos:Vector2):
	position = pos
	cam = get_tree().get_nodes_in_group("shake_vfx")[0]
	timer.wait_time = 1
	timer.start()
	count_down.text = str(wait_time)

func _on_Timer_timeout():
	wait_time -= 1
	count_down.text = str(wait_time)
	if wait_time > 0:
		return
	col.disabled = false
	anim.play("爆炸")
	sfx_explore.play()
	if cam:
		cam.shake_screen(8, 0.2)
	yield(anim,"animation_finished")
	queue_free()

func _on_Area2D_area_entered(area):
	if area.has_method("hit"):
		area.hit()
