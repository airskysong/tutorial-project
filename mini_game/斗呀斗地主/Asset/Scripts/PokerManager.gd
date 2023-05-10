extends Node2D

var pokers = []
var current_role
var roles = []
var current_big_cards := []
var passed_count := 0

onready var poker_prefab = load("res://Asset/Prefabs/Main/Card.tscn") 
onready var poker_pattern = $Poker_patterns
#onready var poker_ai = $Poker_AI
onready var player = $Player
onready var cpu = $CPU
onready var cpu2 = $CPU2

onready var play_out_btn = $CanvasLayer/PlayOutBtn
onready var skinned_btn = $CanvasLayer/SkinnedBtn
onready var btn_tween = $CanvasLayer/btn_tween
onready var timer = $Timer

func _ready():
	randomize()
	pokers = generate_poker()
	shuffle(pokers)
	skinned_btn.hide()
	play_out_btn.hide()
	roles.append(player)
	roles.append(cpu)
	roles.append(cpu2)
	init_connects()
	
#	var new_cards = pokers.duplicate(true)
#	var deck = []
#	for _i in range(3):
#		deck.append(new_cards.pop_back())
#	var datas = division_cards(new_cards, 3)
	
	timer.start(2)
	yield(timer, "timeout")

#	deal_to(player, datas[0])
#	deal_to(cpu, datas[1])
#	deal_to(cpu2, datas[2])
#
#	var test_data1 = [3, 3, 3, 4, 4, 4]
#	var test_data3 = [5, 5, 5, 6, 6, 6]
#	var test_data2 = [7, 7, 7, 8, 8, 8]
#
#	var test_data1 = [3, 3, 4, 4, 5, 5]
#	var test_data3 = [5, 5, 6, 6, 7, 7]
#	var test_data2 = [7, 7, 8, 8, 9, 9]
#
#	var test_data1 = [3, 4, 5, 6, 7]
#	var test_data3 = [4, 5, 6, 7, 8, 9]
#	var test_data2 = [5, 6, 7, 8, 9, 10]

	var test_data1 = [3, 3, 3, 4, 4, 4, 5, 6]
	var test_data3 = [5, 5, 5, 6, 6, 6, 7, 8]
	var test_data2 = [7, 7, 7, 8, 8, 8, 9, 10]

	set_role_cards(roles, [test_data1, test_data2, test_data3])

	current_role = player
	current_role.turn([])
	pass

func init_connects():
	for p in roles:
		p.connect("play_out", self, "on_play_out")
		p.connect("passed", self, "on_passed")
	player.connect("selected", self, "set_btn_active")
	skinned_btn.connect("button_down", player, "on_pass")
	play_out_btn.connect("button_down", player, "on_play_out")
	
#按照A~K顺序生成52张不同id的扑克牌，最后53，54是大王小王
#根据规则赋予对应扑克牌不同的权重，在斗地主里大王最大，小王次之，2和A随后，3最小，其余按花色顺序排列
func generate_poker():
	var result = []
	for id in range(1, 54 + 1):
		var grade : int
		if id == 54:
			grade = 17
		elif id == 53:
			grade = 16
		elif id > 0 && id < 53:
			var num : int = id % 13
			match num:
				1:
					grade = 14
				2:
					grade = 15
				0:
					grade = 13
				_:
					if num in [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]:
						grade = num
		var p = poker_prefab.instance()
		var card_name = get_card_name(id)
		p.name = card_name
		add_child(p)
		p.hide()
		p.init_card(id, grade, card_name)
		result.append(p)
	return result
	
#洗牌
func shuffle(cards:Array):
	cards.shuffle()
	
#发牌, 根据玩家数量返回一个带有不同玩家卡牌数据的字典
func division_cards(cards:Array, player_num):
	var results = {}
	var everyone = cards.size() / player_num
	var count : int = 0
	for x in range(player_num):
		var player_data = []
		for _index in range(everyone):
			player_data.append(cards[count])
			count += 1
		results[x] = player_data
	return results

#为对应的角色发放卡牌
func deal_to(role:Node2D, cards:Array):
	role.init_cards_data(cards)
	
# 根据ID取得扑克牌的名字
func get_card_name(id : int):
		if id == 54:
			return "大王"
		elif id == 53:
			return "小王"
		elif id > 0 && id < 53:
			var num : int = id % 13
			var level = id / float(13)
			var prefix : String
			if level <= 1:
					prefix = "方块"
			elif level <= 2:
					prefix = "梅花"
			elif level <= 3:
					prefix = "红心"
			elif level <= 4:
					prefix = "黑桃"
			match num:
				0:
					return prefix + "K"
				1:
					return prefix + "A"
				11:
					return prefix + "J"
				12:
					return prefix + "Q"
				_:
					if num in [2, 3, 4, 5, 6, 7, 8, 9, 10]:
						return prefix + str(num)

#玩家点选卡牌时的信号调用该方法
func set_btn_active(flags:Array):
	do_tween_btns(play_out_btn, flags[0])
	do_tween_btns(skinned_btn, flags[1])

#按钮的dotween动画效果实现，淡入淡出
func do_tween_btns(var btn, flag:bool):
	var effect :float = 1.0 if flag else 0
	var method_name = "hide" if not flag else "show"
	var to = btn.modulate
	to.a = effect
	btn.disabled = not flag
	btn_tween.interpolate_property(btn, "modulate", modulate, to, 
	0.2, Tween.TRANS_QUINT, Tween.EASE_IN)
	btn_tween.interpolate_callback(btn, 0.2, method_name)
	btn_tween.start()

#每个玩家出牌时的信号调用该方法
func on_play_out(selected_cards:Array):
	var size = current_role.role_cards.size()
	if size == 0:
		on_win(current_role)
		return
	if selected_cards.size() > 0:
		current_big_cards = selected_cards.duplicate(true)
	passed_count = 0
	next_turn()

#玩家们过牌时的信号调用该方法
func on_passed():
	passed_count += 1
	if passed_count == 2:
		passed_count = 0
		current_big_cards.clear()
	next_turn()

#开启下一个回合
func next_turn():
	var index = roles.find(current_role)
	var next = (index + 2) % roles.size()
	current_role = roles[next]
	current_role.turn(current_big_cards.duplicate(true))

#游戏结束时
func on_win(var _role):
	get_tree().reload_current_scene()

#测试用，为角色指定卡牌
func set_role_cards(_roles:Array, grades_list:Array):
	var roles_datas = []
	for x in range(_roles.size()):
		var role_data = []
		for grade in grades_list[x]:
			for poker in pokers:
				if poker.grade == grade:
					role_data.append(poker)
					pokers.erase(poker)
					break
		roles_datas.append(role_data)
		
	for datas in roles_datas:
		for _x in range(17 - datas.size()):
			var temp = pokers.pop_front()
			datas.append(temp)
			pokers.erase(temp)
	
	for x in range(_roles.size()):
		_roles[x].init_cards_data(roles_datas[x])
