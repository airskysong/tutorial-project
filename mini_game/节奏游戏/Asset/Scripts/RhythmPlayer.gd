extends Node2D

signal beat(flag)

onready var beat = preload("res://Asset/Objects/Beats.tscn")
onready var anim = $Center/AnimationPlayer
onready var appraise_tip = $Center/Appraise
onready var center = $Center
onready var perfect_d = $Center/Perfect
onready var good_d = $Center/Good
onready var bad_d = $Center/Bad
onready var timer = $Timer
onready var wave_timer = $WaveTimer

export(float)var start_delay = 2.0
var player
var appraise:int = 0
var has_hit = false
var current_beat_speed 
var min_beat_interval = 0.75

func _ready():
	init_connect()
	randomize()
	player = get_parent()
	if player:
		player.connect("hit", self, "on_hit")
	wave_timer.start(start_delay)


func init_connect():
	perfect_d.connect("area_entered", self, "on_perfect")
	good_d.connect("area_entered", self, "on_good")
	bad_d.connect("area_entered", self, "on_bad")
	wave_timer.connect("timeout", self, "start_wave")


func on_perfect(_area):
	appraise = 3


func on_good(_area):
	appraise = 2


func on_bad(_area):
	appraise = 1


func on_beats_end():
	if not has_hit:
		show_apprase(0)
	appraise = 0
	emit_signal("beat", false)
	has_hit = false


#func _input(event):
#	if event.is_action_pressed("ui_accept") and not has_hit:
#		anim.play("pressed")
#		show_apprase(appraise)


func on_hit():
	anim.play("pressed")
	show_apprase(appraise)

func show_apprase(current:int):
	var result := false
	match current:
		0:
			appraise_tip.set_text("miss",0)
			emit_signal("beat", result)
			return
		1:
			appraise_tip.set_text("bad",0)
		2:
			appraise_tip.set_text("good",1)
			result = true
		3:
			appraise_tip.set_text("perfect",2)
			result = true
	emit_signal("beat", result)
	has_hit = true
		
		
func start_wave():
	var num = randi()%10 + 1
	var speed = rand_range(1, 5)
	for _x in range(num+1):
		create_beats(speed)
		timer.start(min_beat_interval)
		yield(timer, "timeout")
	wave_timer.start(speed)


func create_beats(speed:float):
	var b = beat.instance()
	add_child(b)
	b.connect("finished", self, "on_beats_end")
	b.start(speed, center.global_position)

