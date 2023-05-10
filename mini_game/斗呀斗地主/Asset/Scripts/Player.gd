extends Role

signal selected(flags)

var big_cards := []
onready var timer = $Timer

func _ready():
	destop_area.global_position = global_position + destop_area_offset


func on_play_out():
	if big_cards.size()==0:
		var result = can_play_out_current_card()
	#	print(result)
		if result!=null:
			play_out()
			set_cards_active(false)
	else:
		if poker_patterns.get_match_poker_type(big_cards) == poker_patterns.get_match_poker_type(selected_cards):
			if poker_patterns.get_most_grades(big_cards) < poker_patterns.get_most_grades(selected_cards):
				play_out()
				set_cards_active(false)


func on_pass():
	.on_pass()
	for card in selected_cards:
		move(card, -selecting_offset)
	selected_cards.clear()
	set_cards_active(false)
	emit_signal("selected", [false, false])


func play_out():
	.play_out()
	emit_signal("selected", [false, false])


func select_card(card:Node2D):
	.select_card(card)
	if selected_cards.size() > 0:
		emit_signal("selected", [true, true])
	else:
		emit_signal("selected", [false, true])


func turn(selected_big_cards):
	timer.start(1)
	yield(timer, "timeout")
	.turn(selected_big_cards)
	big_cards = selected_big_cards
	set_cards_active(true)
	if selected_big_cards.size()>0:
		emit_signal("selected", [false, true])
	print("player turn")
	print("need to compare:" + str(big_cards))


func set_cards_active(flag:bool):
	for card in role_cards:
		card.can_control = flag


