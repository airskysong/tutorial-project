extends Node


#解析卡组数据中的牌型
func card_analyze(cards:Array):
#	var datas = cards
	var datas = []
	for card in cards:
		if "grade" in card:
			datas.append(card.grade)
	
	var single = []
	var double = []
	var three = []
	var four = []
	var data_base = {}
	datas.sort()
	print(datas)
	for data in datas:
		var count = datas.count(data)
		if count == 1:
			if not single.has(data):
				single.append(data)
		if count == 2:
			if not double.has(data):
				double.append(data)
		if count == 3:
			if not three.has(data):
				three.append(data)
		if count == 4:
			if not four.has(data):
				four.append(data)
				
	data_base[0] = single
	data_base[1] = double
	data_base[2] = three
	data_base[3] = four
#	data_base[4] = get_single_series(data_base)
#	data_base[5] = get_double_series(data_base)
#	data_base[6] = get_three_series(data_base)
	
	print("单牌：%s"%str(data_base[0]))
	print("对牌：%s"%str(data_base[1]))
	print("三张：%s"%str(data_base[2]))
	print("四张：%s"%str(data_base[3]))
#	print("顺子：%s"%str(data_base[4]))
#	print("双顺：%s"%str(data_base[5]))
#	print("三顺：%s"%str(data_base[6]))
#	print("3带2：%s"%(str(get_three_with_two(data_base))))
#	print("4带1：%s"%(str(get_four_with_one(data_base))))
#	print("飞机带单：%s"%(str(get_plane_combos_with_single(data_base))))
#	print("飞机带双：%s"%(str(get_plane_combos_with_double(data_base))))
	return data_base

#从牌堆中取得单顺的组合,level表示是否拆除其它的牌组
func get_single_series(data_base:Dictionary, level=null):
	var single_series = data_base[0]
	var two_series = data_base[1]
	var three_series = data_base[2]
	var four_series = data_base[3]
	var series = []
	if not level:
		series.append_array(single_series)
		series.append_array(two_series)
		series.append_array(three_series)
		series.append_array(four_series)
	else:
		if level>=0:
			series.append_array(single_series)
		if level>=1:
			series.append_array(two_series)
		if level>=2:
			series.append_array(three_series)
		if level>=3:
			series.append_array(four_series)
	series.sort()
	return get_series(series, 5)

#从牌堆中取得双顺的组合，level表示是否拆除其它的牌组
func get_double_series(data_base:Dictionary, level=null):
	var two_series = data_base[1]
	var three_series = data_base[2]
	var four_series = data_base[3]
	var series = []
	if not level:
		series.append_array(two_series)
		series.append_array(three_series)
		series.append_array(four_series)
	else:
		if level>=1:
			series.append_array(two_series)
		if level>=2:
			series.append_array(three_series)
		if level>=3:
			series.append_array(four_series)
	series.sort()
	return get_series(series, 3)

#从牌堆中取得三顺的组合，level表示是否拆除其它的牌组
func get_three_series(data_base:Dictionary, level=null):
	var three_series = data_base[2]
	var four_series = data_base[3]
	var series = []
	if not level:
		series.append_array(three_series)
		series.append_array(four_series)
	else:
		if level>=2:
			series.append_array(three_series)
		if level>=3:
			series.append_array(four_series)
	return get_series(series, 2)

#输入检测数据和需要返回连续数据的数组大小，得到大于等于长度size的连续数据
func get_series(data:Array, size:int):
	var result = []
	var temp = []
	var last : int
	for index in range(data.size()):
		var current = data[index]
		if index == 0:
			last = current
			temp.append(current)
			continue
		if current == last + 1:
			last = current
			if current < 16:
				temp.append(current)
		if current != last or index == data.size() - 1:
			if temp.size()>=size:
				result.append_array(temp)
			temp.clear()
			last = current
			temp.append(last)
	return result

#检测牌组中的三带二组合
func get_three_with_two(data_base:Dictionary):
	var result = {}
	var three = data_base[2]
	var two = data_base[1]
	if three.size()>0 and two.size()>0:
		for x in range(three.size()):
			var index = three[x]
			result[index] = two
	return result
	
#检测牌组中的四带一组合
func get_four_with_one(data_base:Dictionary):
	var result = {}
	var four = data_base[3]
	var one = data_base[0]
	if four.size()>0 and one.size()>0:
		for x in range(four.size()):
			var index = four[x]
			result[index] = one
	return result

#检测牌组中的飞机组合，带单
func get_plane_combos_with_single(data_base:Dictionary):
	var result = []
	var three_series = get_three_series(data_base, 2)
	var one:= []
	one.append_array(data_base[0])
	one.append_array(data_base[1])
	var size = three_series.size()
	if size>=2 and one.size()>=size:
		result.append(three_series)
		result.append(one)
	return result

#检测牌组中的飞机组合，带双
func get_plane_combos_with_double(data_base:Dictionary):
	var result = {}
	var three_series = get_three_series(data_base, 2)
	var two = data_base[1]
	var size = three_series.size()
	if size>=2 and two.size()>=size :
		result.append(three_series)
		result.append(two)
	return result

#检测牌组中的最大牌，火箭（双joker）
func get_rocket(data_base:Dictionary):
	if 16 in data_base[0] and 17 in data_base[0]:
		return [16, 17]
