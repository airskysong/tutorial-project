extends Node2D

export(int) var scroll_speed = 10

onready var pbg := $ParallaxBackground

var ninja_model = preload("res://Asset/Objects/主场景/忍者.tscn")
var small_mission_model = preload("res://Asset/Objects/主场景/小导弹.tscn")
var big_mission_model = preload("res://Asset/Objects/主场景/大导弹.tscn")
var coin_model = preload("res://Asset/Objects/主场景/金币.tscn")
var warning_model = preload("res://Asset/Objects/主场景/警告提示.tscn")

onready var wave_timer = $WaveTimer
onready var coin_timer = $CoinTimer

var screen_size : Vector2 
var player

func _ready():
	randomize()
	GlobalVals.score = 0
	screen_size = get_viewport_rect().size
	create_player(screen_size/2)
	new_wave()
	wave_timer.start()

func _process(delta):
	pbg.scroll_offset.x -= scroll_speed * delta

func new_wave():
	rand_action()


func rand_action():
	var rand = rand_range(0, 100)
	if rand<50:
		action1()
	else:
		action2()
	var time = wave_timer.time_left - 0.5
	coin_timer.start(rand_range(0, time))


func action1():
	var offset:float = 50
	var total = int(rand_range(1, 4))
	var all_pos = []
	var start_pos = Vector2(screen_size.x, 
	rand_range(0, screen_size.y -  offset))
	for index in range(total):
			var current_pos = start_pos + Vector2.DOWN * offset * index
			all_pos.append(current_pos)
			if index == 0:
				continue
			show_warning(current_pos)
	yield(show_warning(start_pos), "completed")
	for pos in all_pos:
		create_big_mission(pos)


func action2():
	var offset:float = 50
	var total = int(rand_range(1, 4))
	var all_pos = []
	var start_pos = Vector2(screen_size.x, 
	rand_range(0, screen_size.y -  offset))
	for index in range(total):
			var current_pos = start_pos + Vector2.DOWN * offset * index
			all_pos.append(current_pos)
			if index == 0:
				continue
			show_warning(current_pos)
	yield(show_warning(start_pos), "completed")
	for pos in all_pos:
		create_small_mission(pos)


func show_warning(pos:Vector2):
	var f = warning_model.instance()
	add_child(f)
	f.spawn(pos)
	yield(f, "finish")

func create_player(pos:Vector2):
	var p = ninja_model.instance()
	player = p
	add_child(p)
	p.connect("player_die", self, "on_player_die")
	p.position = pos

func create_small_mission(pos:Vector2):
	var m = small_mission_model.instance()
	add_child(m)
	m.spawn(player, pos)

func create_big_mission(pos:Vector2):
	var b = big_mission_model.instance()
	add_child(b)
	b.position = pos

func create_coins_group(start:Vector2, column:int, row:int, offset_x:int, offset_y:int):
	var coins_group = []
	var size 
	start = Vector2(start.x, clamp(start.y, 20, screen_size.y))
	for y in range(row):
		for x in range(column):
			var c = coin_model.instance()
			add_child(c)
			if not size:
				size = c.get_size() * c.scale.x
			var offset = Vector2(x * (offset_x + size.x),
			y * (offset_y + size.y))
			c.position = start + offset
			coins_group.append(c)
	var last_coin = coins_group[coins_group.size() - 1]
	if last_coin.position.y + size.y / 2 > screen_size.y:
		var _offset_y =  screen_size.y - size.y - last_coin.position.y
		for c in coins_group:
			c.position +=  Vector2(0, _offset_y)

func _on_Timer_timeout():
	new_wave()


func _on_CoinTimer_timeout():
	var pos = Vector2(screen_size.x, 
	rand_range(0, screen_size.y))
	create_coins_group(pos, 
	int(rand_range(2, 6)),
	int(rand_range(1, 5)),
	8, 8)

func on_player_die():
	SceneTransition.change_and_translate_scene("res://Asset/Objects/结束模块/结束模块.tscn")
