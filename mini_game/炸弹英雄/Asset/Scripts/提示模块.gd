extends Label

onready var anim := $AnimationPlayer

func show_tip(content:String):
	text = content
	anim.play("入场动画")
#	get_tree().paused = true
	yield(anim,"animation_finished")
#	get_tree().paused = false
