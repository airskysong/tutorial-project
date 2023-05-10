extends Node2D

export(int) var grid_size = 64
export(float) var step_time = 0.6 setget set_speed

onready var head_node := $"头"
onready var body_nodes := $"身体"
onready var timer := $Timer

onready var body_pref = preload("res://Asset/Object/主场景/身体节点.tscn")

var move_dir : Vector2
var length
var can_input = true
var touch_input
var center_pos

signal player_fail

func _ready():
	init()
	start_move()
	
func init():
	timer.wait_time = step_time
	timer.connect("timeout", self, "move")
	move_dir = Vector2.RIGHT
	touch_input = InputEventAction.new()
	center_pos = get_viewport_rect().size / 2

func set_speed(value):
	step_time = value
	timer.wait_time = step_time


func _process(_delta):
	if not can_input:
		return
	
	if Input.is_action_pressed("ui_left") and move_dir != Vector2.RIGHT:
		move_dir = Vector2.LEFT
		can_input = false
	if Input.is_action_pressed("ui_right") and move_dir != Vector2.LEFT:
		move_dir = Vector2.RIGHT
		can_input = false
	if Input.is_action_pressed("ui_up") and move_dir != Vector2.DOWN:
		move_dir = Vector2.UP
		can_input = false
	if Input.is_action_pressed("ui_down") and move_dir != Vector2.UP:
		move_dir = Vector2.DOWN
		can_input = false
#	if Input.is_action_pressed("测试"):
#		add_body_node()

func _input(event):
		
	if event is InputEventScreenTouch and event.is_pressed():
		var dir = event.position - head_node.global_position
		var action_name : String
		if abs(dir.x) > abs(dir.y):
			action_name = "ui_left" if dir.x < 0 else "ui_right"
		elif abs(dir.x) < abs(dir.y):
			action_name = "ui_up" if dir.y < 0 else "ui_down"
		
		Input.action_release(touch_input.action)
		touch_input.action = action_name
		touch_input.pressed = true
		Input.parse_input_event(touch_input)
		
	if event is InputEventScreenTouch and not event.is_pressed():
		Input.action_release(touch_input.action)

#
		
func start_move():
	timer.start()

func stop_move():
	move_dir = Vector2.ZERO
	timer.stop()

func move():
	var body : Array = body_nodes.get_children()
	length = body_nodes.get_child_count()
	
	if length > 1:
		for index in range(length - 1, 0, -1):
			set_pos_and_rotation(body[index], body[index-1])
	if length > 0:	
		set_pos_and_rotation(body[0], head_node)
	
#	head_node.rotation = move_dir.angle() - PI * 0.5
	head_node.position += move_dir * grid_size
	can_input = true

func add_body_node():
	var b = body_pref.instance()
	var count = body_nodes.get_child_count()
	body_nodes.call_deferred("add_child", b)
	if count > 0:
		var last_node = body_nodes.get_child(count-1)
		b.set_deferred("monitorable", true)
		b.set_deferred("monitoring", true)
		set_pos_and_rotation(b, last_node)

	else:
		set_pos_and_rotation(b, head_node)


func _on__area_entered(area):
	if area.collision_layer == 2:
		area.queue_free()
		add_body_node()
	if area.collision_layer == 4:
		player_fail()
		
func set_pos_and_rotation(node1, node2):
	node1.position = node2.position
#	node1.rotation = node2.rotation

func player_fail():
	stop_move()
	emit_signal("player_fail")
	

