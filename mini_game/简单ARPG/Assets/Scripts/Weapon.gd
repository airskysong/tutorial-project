extends Node2D

export(int) var damage = 1

onready var attack_detector := $sprite/Attack_detector

func _ready():
	attack_detector.connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if body.has_method("take_hit"):
		body.take_hit(damage)
