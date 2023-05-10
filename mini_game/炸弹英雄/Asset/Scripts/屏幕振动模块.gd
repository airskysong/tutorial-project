extends Camera2D
# 黏贴至相机
onready var tween = $Tween
class_name VFXCam

func _ready():
	randomize()
	add_to_group("shake_vfx")

func shake_screen(strength:float, duration:float):
	tween.interpolate_method(self, "_shake_screen",
	strength, 0, duration,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()

func _shake_screen(strength:float):
	offset.x = rand_range(-strength, strength)
	offset.y = rand_range(-strength, strength)
