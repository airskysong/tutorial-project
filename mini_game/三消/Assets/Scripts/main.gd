extends Node2D

onready var hit_pg = $"CanvasLayer/Control/连击条"
onready var hit_lb = $"CanvasLayer/Control/连击文本"
onready var score_lb = $"CanvasLayer/Control/MarginContainer/分数文本"
onready var element_m = $"元素管理器"
onready var anim = $"CanvasLayer/Control/连击文本/AnimationPlayer"

var is_on_hit_time : bool = false
var score :int = 0
var hits : int = 0
var max_hits : int = 0


func _ready():
	hit_pg.connect("hit_finished", self, "on_hit_finished")
	element_m.connect("disposed", self, "on_elements_disposed")


func on_hit_finished():
	max_hits = hits
	hits = 0
	update_ui()
	hit_lb.hide()
	

func on_elements_disposed(_element_type:int):
	score += 10
	hits += 1
	update_ui()
	hit_pg.begin()

		
func update_ui():
	score_lb.text = "socre: "+str(score)
	hit_lb.show()
	hit_lb.text = str(hits) + " hit"
