extends Node2D

onready var tween = $Tween
onready var color_rect = $CanvasLayer/ColorRect
export var fade_transition = 0.3

enum{IN, OUT, IDLE, BLACK}

var state := IDLE setget set_state
var percent := 0.0 setget set_percent

signal fade_completed

func _ready():
	color_rect.rect_min_size = get_viewport_rect().size
	color_rect.modulate.a = 0
	tween.connect("tween_all_completed", self, "fade_finished")
	
func set_percent(value:float)->void:
	value = clamp(value, 0, 1)
#	color_rect.material.set_shader_param("alpha", value)
	color_rect.modulate.a = value

func set_state(value:int)->void:
	match value:
		IN:
			tween.interpolate_property(self, "percent", 1, 0, 
			fade_transition, Tween.TRANS_LINEAR,Tween.EASE_IN)
		OUT:
			tween.interpolate_property(self, "percent", 0, 1,
			 fade_transition, Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()

			
func fade_finished():
	match state:
		IN:
			state = IDLE
		OUT:
			state = BLACK
		
	emit_signal("fade_completed")

func change_and_translate_scene(var path):
	if self.state == IDLE:
		self.state = OUT
		yield(self, "fade_completed")
		get_tree().change_scene(path)
		self.state = IN
