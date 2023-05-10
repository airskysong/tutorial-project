extends Area2D

var damage:int = 0

func _ready():
	self.connect("area_entered", self, "on_area_entered")
	
func on_area_entered(area):
	if area.has_method("get_hit"):
		area.get_hit(damage)
