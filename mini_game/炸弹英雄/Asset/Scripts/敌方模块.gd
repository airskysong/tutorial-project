extends Area2D

var move_speed : int = 32

onready var sp := $AnimatedSprite

var target:Area2D 
var velocity:Vector2

func _ready():
	add_to_group("enemies")

func spawn(pos:Vector2, _target:Area2D):
	position = pos
	target = _target
	
func _process(delta):
	if target:
		velocity = (target.position - position).normalized() * move_speed
		position += velocity * delta
		set_direction(velocity)


func hit():
	GlobalVal.score += 1
	queue_free()


func _on__area_entered(area):
	if area.has_method("hit"):
		area.hit()

func set_direction(face:Vector2):
	if face.x < 0:
		sp.flip_h = true
	elif face.x > 0:
		sp.flip_h = false
