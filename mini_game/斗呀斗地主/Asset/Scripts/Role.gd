extends Node2D
class_name Role

signal play_out(destopf_area)
signal passed

export(Vector2) var selecting_offset = Vector2(0, -50)
export(Vector2) var destop_area_offset = Vector2(0, -64)


var is_horizontal = true
var can_control = true
var duration = 0.15
var role_cards:=[]
var selected_cards := []
var destop_cards := []

onready var tween = $Tween
onready var poker_patterns = $Poker_patterns
onready var destop_area = $DestopArea


func init_cards_data(card_list:Array):
	role_cards = card_list
	for card in card_list:
		if can_control:
			card.connect("pressed", self, "select_card")
		else:
			card.can_control = false
		var parent = card.get_parent()
		parent.remove_child(card)
		add_child(card)
	dispose_card(card_list)


func select_card(card:Node2D):
#	print(card.card_name)
	if tween.is_active():
		return 
	if not card in selected_cards:
		selected_cards.append(card)
		move(card, selecting_offset)
	else:
		selected_cards.erase(card)
		move(card, -selecting_offset)


func move(card:Node2D, offset:Vector2):
	tween.interpolate_property(card, "global_position", card.global_position, 
	card.global_position + offset, duration, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()

#排列手卡
func dispose_card(card_list:Array):
	sort_cards_list(card_list)
	var size = card_list.size()
	for index in range(size):
		var card = card_list[index]
		set_card_pos(card, index, size, global_position, false)

#设置对应卡牌的位置
func set_card_pos(card, index:int, size: int, start_pos:Vector2, ignore:bool):
# warning-ignore:integer_division
	var i = index - size / 2
	if size > 5:
		var radio = 0.84 - 0.02 * size
		i = i * radio
	var pos_x
	var pos_y
	if is_horizontal or ignore:
		var card_width = card.get_card_size().x
		pos_x = card_width * (i + 0.5) + start_pos.x 
		pos_y = start_pos.y
	else:
		var card_heigh = card.get_card_size().y
		pos_y = card_heigh * i * 0.7 +  start_pos.y
		pos_x = start_pos.x
	card.show()
	card.raise()
#	card.global_position = Vector2(pos_x, pos_y)
	var offset = Vector2(pos_x, pos_y) - card.global_position
	move(card, offset)

#按牌值对列表进行排序
func sort_cards_list(card_list:Array):
	var size = card_list.size()
	for index in range(size):
		for next in range(index + 1, size): 
			if card_list[index].grade <= card_list[next].grade:
				if card_list[index].grade == card_list[next].grade:
					if not card_list[index].id < card_list[next].id:
						continue
				var temp = card_list[index] 
				card_list[index]  = card_list[next]
				card_list[next] = temp

#根据规则判断选择手卡的类型
func can_play_out_current_card():
	sort_cards_list(selected_cards)
	return poker_patterns.get_match_poker_type(selected_cards)

#出牌
func play_out():

	if selected_cards == null:
		emit_signal("play_out", selected_cards)
		return

	sort_cards_list(selected_cards)
	var size = selected_cards.size()
	for index in range(size):
		var card = selected_cards[index]
		role_cards.erase(card)
		card.can_control = false
		set_card_pos(card, index, size, destop_area.global_position, true)
		remove_child(card)
		destop_cards.append(card)
		destop_area.add_child(card)

	selected_cards.clear()
	dispose_card(role_cards)
	emit_signal("play_out", destop_cards)

func turn(_selected_big_cards):
	clear_destop_area()
	
	
func on_pass():
	emit_signal("passed")

func clear_destop_area():
	if destop_cards.size()>0:
		for card in destop_cards:
			card.hide()
		destop_cards.clear()
