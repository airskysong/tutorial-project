extends Role

onready var poker_ai = $Poker_AI
onready var timer = $Timer

func _ready():
	is_horizontal = false
	destop_area.global_position = global_position + destop_area_offset

#开启Ai的决策，简单的if...else...
func start_Ai(selected_big_cards):
	print(self.name + " turn:")
	print("compare_card" + str(selected_big_cards))
	
	var analyze = poker_ai.card_analyze(role_cards)
	var grade_list := []

	if selected_big_cards.size()==0:
		grade_list = get_one_type_grade_list(analyze)
	else:
		grade_list = get_matched_grade_list(selected_big_cards, analyze)
	
	if grade_list.size()>0:
		selected_cards = get_matched_card_list(grade_list, role_cards)
		play_out()
		print("play_out:"+str(grade_list))
	else:
		on_pass()
		print("pass")
		
#继承父类的方法，表示出牌
func play_out():
	timer.start(2)
	yield(timer, "timeout")
	.play_out()
	
#继承父类的方法，表示无法出牌时过牌
func on_pass():
	timer.start(2)
	yield(timer, "timeout")
	.on_pass()

#Cpu获得本回合的主导权时，返回一个可以出牌的基础牌型
func get_one_type_grade_list(analyze_data:Dictionary):
	var grade_list = []
	for index in range(analyze_data.size()):
		if index > 4:
			return []
		var card_types_array = analyze_data[index]
		if card_types_array.size()>0:
			var times = index + 1
			for _time in range(0, times):
				grade_list.append(card_types_array[0])
			return grade_list
	return grade_list
	
#继承父类对象的方法turn，外部调用该方法开启本回合
func turn(selected_big_cards):
	.turn(selected_big_cards)
	start_Ai(selected_big_cards)

#解析上家的牌型，并从手牌返回大于它的对应卡组数据，如果没有则返回空数组
func get_matched_grade_list(compare_card_list:Array, analyze):
	var result := []
	var compare_card_length = compare_card_list.size()
	var pokers_type = poker_patterns.get_match_poker_type(compare_card_list)
	print("the pokers_type is ："+str(pokers_type))
	var compare = poker_patterns.get_most_grades(compare_card_list)
		#单牌,对子，3张，4张
	if pokers_type in [0, 1, 2, 3]:
		result = get_base_type_bigger_grades(pokers_type, compare, analyze)
	elif pokers_type == 4:
		result = get_base_x_with_y_type_bigger_grades(compare, analyze, 3, 2)
		pass
	elif pokers_type == 5:
		result = get_base_x_with_y_type_bigger_grades(compare, analyze, 4, 1)
	elif pokers_type == 6:
		result = get_base_x_with_y_type_bigger_grades(compare, analyze, 4, 2)
	elif pokers_type in [7, 8, 9]:
		var x = pokers_type - 6
		result = get_x_bigger_series_grades(x, compare, compare_card_length, 
		analyze)
	elif pokers_type == 10:
		result = get_plane_with_single_grades(compare, compare_card_length, 
		analyze)
	return result

#从牌型数据中取得大于compare值的飞机带单牌型，没有则返回空数组
func get_plane_with_single_grades(compare:int, series_size:int, 
analyze: Dictionary):
	var result = []
	var plane_data = poker_ai.get_plane_combos_with_single(analyze)
	if plane_data.size()<1:
		return result
	var three = plane_data[0]
	var single = plane_data[1]
	var three_part_length = series_size / float(4)
	var compare_head_grades = compare - three_part_length + 1
	print("plane_data:"+str(plane_data))
	print("three_parth_length:"+str(three_part_length))
	print("compare_head_grades:"+str(compare_head_grades))
	var count : int = 0
	for index in range(three.size()):
		var grade = three[index]
		if grade > compare_head_grades:
			count += 1
			for _t in range(3):
				result.append(grade)
			if count >= three_part_length:
				for _t in range(three_part_length):
					result.append(single[_t])
				return result
	return []

#x表示x连顺，即x＝1单连顺，x＝2双顺，x＝3三顺，从牌型数据中取得大于compare值的牌型数据
#如果没有则返回一个空数组
func get_x_bigger_series_grades(x:int, compare:int, series_size:int,
analyze:Dictionary):
	var result = []
	if not x in [1, 2, 3]:
		return result
	#顺子中最小的牌
	var compare_head_grades = compare - series_size / float(x) + 1
	var series_data
	match x:
		1:
			series_data = poker_ai.get_single_series(analyze, 2)
		2:
			series_data = poker_ai.get_double_series(analyze, 2)
		3:
			series_data = poker_ai.get_three_series(analyze, 2)
	var count = 0
	if series_data.size()>0:
		print("series data is:%s"%[str(series_data)])
		for index in range(series_data.size()):
			if series_data[index] > compare_head_grades:
				count += 1
				for _t in range(x):
					result.append(series_data[index])
				if count >= series_size / float(x):
					return result
	return []

#输入x和y，代表x带y的类型，从牌型数据中取得大于compare值的牌型，没有则返回空数组
func get_base_x_with_y_type_bigger_grades(compare:int, analyze:Dictionary, 
base_x:int, base_y:int):
	var result = []
	var size = analyze.size()
	var index_x = base_x - 1
	var index_y = base_y - 1
	if not index_x in range(0, size) or not index_y in range(0, size):
		return result
	var x_type = analyze[index_x]
	var y_type = analyze[index_y]
	for grade in x_type:
		if grade > compare:
			var with_grade = y_type[0]
			for _t in range(base_x):
				result.append(grade)
			for _t in range(base_y):
				result.append(with_grade)
			return result
	return result

#从牌组解析中取得符合基础重复类型的牌型，单张，对子，三张，四张等，不包含拆牌
func get_base_type_bigger_grades(math_type:int, compare:int, 
card_database:Dictionary):
	var result = []
	var type_list = card_database[math_type]
	var biger_grade = get_biger_grade(type_list, compare)
	if biger_grade:
		for _time in range(0, math_type + 1):
			result.append(biger_grade)
	return result

#从一个数据中返回大于compare的数据
func get_biger_grade(datas:Array, compare:int):
	for data in datas:
		if data > compare:
			return data
	return null

#输入grade值和牌组对象列表，返回一个对应牌的对象
func get_matched_card(grade:int, card_list:Array):
	for card in card_list:
		if card.grade == grade:
			card_list.erase(card)
			return card
	return null

#输入一个grade值列表和牌组对象列表，返回对应grade值的卡组列表
func get_matched_card_list(grade_list:Array, hand_card_list:Array):
	var list = []
	var card_list = hand_card_list.duplicate(true)
	if grade_list.size() > 0:
		for p in grade_list:
			var card = get_matched_card(p, card_list)
			if card!=null:
				list.append(card)
	return list
