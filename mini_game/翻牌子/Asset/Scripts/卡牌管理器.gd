extends Node2D

signal one_turn

export(int) var match_card_num = 2
export(Vector2) var card_spaing = Vector2(32, 32)
export(Vector2) var bg_size = Vector2(500, 350) 
export(Vector2) var grids_size = Vector2(1, 1)
export(Vector2) var card_size = Vector2(64, 64)
export(float) var stay_time = 1.5

var pos_list = []
var card_list = []
var selecting_card 
var radio 

onready var bg := $ColorRect
onready var card_preb = preload("res://Asset/Objects/主场景/牌.tscn")
onready var card_anchor = $cards
onready var area := $cards/ColorRect2
onready var timer := $Timer

func _ready():
	randomize()
	bg.rect_min_size = bg_size
	set_to_screen_center()
	init_grids()
	init_card_data()
	
	
func set_to_screen_center():
	global_position = get_viewport_rect().size * 0.5 - bg_size * 0.5


func init_grids():
	var offset_x = card_size.x + card_spaing.x 
	var offset_y = card_size.y + card_spaing.y
	var start_pos = Vector2(
		card_size.x * 0.5 + card_spaing.x,
		card_size.y * 0.5 + card_spaing.y
		)
	
	var column = grids_size.y
	var row = grids_size.x
	for y in column:
		for x in row:
			var pos_x = start_pos.x  + offset_x * x 
			var pos_y = start_pos.y  + offset_y * y
			pos_list.append(Vector2(pos_x, pos_y))
	
	var grid_width = (row + 1) * card_spaing.x + row * card_size.x
	var grid_heigh = (column  + 1) * card_spaing.y + column * card_size.y
	
#	area.rect_min_size = Vector2(grid_width, grid_heigh)
	
	if grid_width >= grid_heigh:
		radio = bg_size.y / float(grid_heigh)
	else:
		radio = bg_size.x / float(grid_width)

	card_anchor.scale = Vector2.ONE * radio
	card_anchor.position = Vector2(
		(bg_size.x - grid_width * radio) * 0.5, 
		(bg_size.y - grid_heigh * radio) * 0.5
		)


func init_card_data():
	var match_count = 0
	var card_type = 0
	var rand_pos = get_random_array(pos_list)
	for pos in rand_pos:
		var c = card_preb.instance()
		c.connect("clicked", self, "on_card_clicked")
		card_anchor. add_child(c)
		c.init(pos, card_type)
		card_list.append(c)
		
		match_count += 1
		if match_count == match_card_num:
			 match_count = 0
			 card_type += 1


func get_random_element_in_Array(list:Array):
	var index = int(rand_range(0, list.size()))
	var child = list[index]
	list.remove(index)
	return child
	
func get_random_array(array:Array):
	var new : Array = array.duplicate(true)
	var size = new.size()
	var another : Array = []
	for _x in range(size):
		var element = get_random_element_in_Array(new)
		another.append(element)
	return another


func on_player_win():
	get_tree().reload_current_scene()


func on_card_clicked(card):
	if not selecting_card:
		selecting_card = card
		selecting_card.is_front = true
		timer.start(stay_time)
	else:
		if selecting_card == card:
			return
		if selecting_card.card_type == card.card_type:
			timer.stop()
			selecting_card.can_selecting = false
			card.is_front = true
			card.can_selecting = false
			selecting_card = null
		else:
			selecting_card.is_front = false
			card.is_front = true
			selecting_card = card
			timer.start(stay_time)
	emit_signal("one_turn")
	check()
	
	
func check():
	var count = 0
	for card in card_list:
		if not card.can_selecting:
			count += 1
	if count == card_list.size():
		on_player_win()
	

func _on_Timer_timeout():
	if selecting_card:
		selecting_card.is_front = false
		selecting_card = null
