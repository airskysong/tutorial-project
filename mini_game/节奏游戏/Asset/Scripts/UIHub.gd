extends Control

var max_health = 100
var max_energy = 100
var duration = 1

onready var health_p = $Health
onready var energy_p = $Energy
onready var health_tween = $Health/Tween
onready var energy_tween = $Energy/Tween


func _ready():
	health_p.value = max_health
	energy_p.value = max_energy


func do_tween_change_progress(tween:Tween, bar:ProgressBar, 
from:float, to:float, _duration:float):
		tween.interpolate_property(bar, "value", from, to, _duration, 
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()


func set_health_ui(health:int):
	var from = health_p.value
	do_tween_change_progress(health_tween, health_p,
	from, health, duration)
	

func set_energy_ui(energy:int):
	var from = energy_p.value
	do_tween_change_progress(energy_tween, energy_p,
	from, energy, duration)
