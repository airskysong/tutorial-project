extends Node

export(Array, int) var card_data = []

enum {
	single,
	double,
	three,
	bomb,
	three_with_two,
	four_with_one,
	four_with_two,
	single_series,
	double_series,
	three_series,
	plane_series_single,
	plane_series_two,
	rocket,
}


func get_match_poker_type(card_list:Array):
	var datas = get_grade_by_card(card_list)
	datas.sort()
#	print(datas)
	if is_valid_single(datas):
		return single
	elif is_valid_double(datas):
		return double
	elif is_valid_Three(datas):
		return three 
	elif is_valid_rocket(datas):
		return rocket
	elif is_valid_bomb(datas):
		return bomb
	elif is_valid_Three_with_two(datas):
		return three_with_two
	elif is_valid_four_with_one(datas):
		return four_with_one
	elif is_valid_single_series(datas):
		return single_series
	elif is_valid_double_series(datas):
		return double_series
	elif is_valid_three_series(datas):
		return three_series 
	elif is_valid_four_with_two(datas):
		return four_with_two
	else:
		var num = is_valid_plane_series(datas)
		if num == 1:
			return plane_series_single
		elif num == 2:
			return plane_series_two
	return null

#单牌
func is_valid_single(data:Array):
	if data.size() == 1:
		return true
	return false

#对牌
func is_valid_double(data:Array):
	if data.size() == 2:
		if data[0] == data[1]:
			return true
	return false

#三张一样的牌
func is_valid_Three(data:Array):
	if data.size() == 3:
		var num = data[0]
		if data.count(num) == 3:
			return true
	return false

#火箭王炸，大王小王
func is_valid_rocket(data:Array):
	if data.size() == 2:
		if data[0] == 16 and data[1] == 17:
			return true
	return 

#4张一样的牌，炸弹
func is_valid_bomb(data:Array):
	if data.size() == 4:
		var num = data[0]
		if data.count(num) == 4:
			return true
	return false

#三张带一对
func is_valid_Three_with_two(data:Array):
	if data.size() == 5:
		var num1 = data[0]
		var num2 = data[4]
		if data.count(num1) == 3 and data.count(num2) == 2:
			return true
		if data.count(num1) == 2 and data.count(num2) == 3:
			return true
	return false

#四张带一张
func is_valid_four_with_one(data:Array):
	if data.size() == 5:
		var num1 = data[0]
		var num2 = data[4]
		if data.count(num1) == 4 and data.count(num2) == 1:
			return true
		if data.count(num1) == 1 and data.count(num2) == 3:
			return true
	return false

#顺子，5张或者5张以上连续单牌，不包括2和双王
func is_valid_single_series(data:Array):
	if data.size() >= 5:
		var last : int = 0
		for check in data:
			if check in [15, 16, 17]:
				return false
			if last == 0:
				last = check
				continue
			if check == last + 1:
				last = check
			else:
				return false
		return true
	else:
		return false

#双顺，以2张大小相同的牌为基本单位，三个或者更多个单位构成的连续顺序牌组，不包含2和大小王
func is_valid_double_series(data:Array):
	if data.size() >= 6 and data.size()%2==0:
		var last_fst : int = 0
		var last_sec : int = 0
		for index in range(0, data.size(), 2):
			if data[index] in [15, 16, 17]:
				return false
			elif last_fst == 0 and last_sec == 0:
				last_fst = data[index]
				last_sec = data[index + 1]
				if last_fst != last_sec:
					return false
				continue
			
			if data[index] == last_fst+1 and data[index+1] == last_sec + 1:
				last_fst = data[index]
				last_sec = data[index + 1]
			else:
				return false
		return true
	else:
		return false

#三顺，以3张大小相同的牌为基本单位，两个或者更多个单位构成的连续顺序牌组
func is_valid_three_series(data:Array):
	if data.size() >= 6 and data.size()%3==0:
		var last_fst : int = 0
		var last_sec : int = 0
		var last_trd : int = 0
		for index in range(0, data.size(), 3):
			if data[index] in [15, 16, 17]:
				return false
			elif last_fst == 0 and last_sec == 0 and last_trd == 0:
				last_fst = data[index]
				last_sec = data[index + 1]
				last_trd = data[index + 2]
				if last_fst != last_sec or last_sec!=last_trd:
					return false
				continue
			
			if data[index] == last_fst+1 and data[index+1] == last_sec + 1:
				if data[index+2] == last_trd + 1:
					last_fst = data[index]
					last_sec = data[index + 1]
					last_trd = data[index + 2]
				else:
					return false
			else:
				return false
		return true
	else:
		return false

#四带二
func is_valid_four_with_two(data:Array):
	if data.size() == 6:
		var num1 = data[0]
		var num2 = data[5]
		if data.count(num1) == 4 and data.count(num2) == 2:
			return true
		if data.count(num1) == 2 and data.count(num2) == 4:
			return true
	return false

#飞机带翅膀，符合三顺+三顺数量的对子或单牌
func is_valid_plane_series(data:Array):
	if data.size() in [8, 10, 12, 15, 16]:
		var single = []
		var double = []
		var three = []
		for index in range(0, data.size()):
			var current = data[index]
			if data.count(current) == 1:
				if not single.has(current):
					single.append(current)
			elif data.count(current) == 2:
				if not double.has(current):
					double.append(current)
			elif data.count(current) == 3:
				if not three.has(current):
					three.append(current)
		#是否符合三顺
		if three.size() < 2:
			return 0
		var combo : int
		for i in three:
			if i == three[0] :
				combo = i
				continue
			if i == combo + 1:
				combo = i
			else:
				return 0
		#带牌不能同时有对子和单排
		if double.size()>0 and single.size()>0:
			return 0
		#带牌对子数量必须和三顺的数量一致
		if double.size()>0 and three.size()!=double.size():
			return 0
		#带牌单排数量必须和三顺数量一致
		if single.size()>0 and three.size()!=single.size():
			return 0
		
		if double.size() == three.size():
			return 2
		if single.size() == three.size():
			return 1
	else:
		return 0

func get_most_grades(card_list:Array):
	var datas = get_grade_by_card(card_list)
	var record : int = 0
	var grades : int
	datas.sort()
	for data in datas:
		var count = datas.count(data)
		if count >= record:
			record = count
			grades = data
	return grades

func get_grade_by_card(card_list:Array):
	var datas = []
	for card in card_list:
		if "grade" in card:
			datas.append(card.grade)
	return datas
