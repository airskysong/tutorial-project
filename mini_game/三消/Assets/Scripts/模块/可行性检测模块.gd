extends module

var grids = []
var map_size:Vector2
var match_elements = []

onready var next_module1 := load("res://Assets/Modules/主场景/消除模块.tscn")
onready var next_module2 := load("res://Assets/Modules/主场景/控制输入模块.tscn")
onready var timer := $Timer


func init(_manager):
	manager = _manager
	grids = manager.grids
	map_size = manager.map_size
	match_elements = manager.match_elements


func begin_handle():
	.begin_handle()
	if check_two_element_will_match():
		go_to_next_module(next_module2)
	else:
		clear_map()
		go_to_next_module(next_module1)


#检测是否有栅格地图中是否有两个元素即将满足三消
func check_two_element_will_match():
	#从左到右，检测连续两个相同元素排列的情况
	for y in range(map_size.y):
		for x in range(map_size.x - 1): 
			var e1 = grids[y][x]
			var e2 = grids[y][x+1]
			if e1.element_type == e2.element_type:
				if manager.is_valid_grid_pos(x-1, y):
					if is_same_type_neigbhour(x-1, y, e1):
						return true
				if manager.is_valid_grid_pos(x+2, y):
					if is_same_type_neigbhour(x+2, y, e2):
						return true
	#从上到下检测连续两个元素排列的情况
	for x in range(map_size.x):
		for y in range(map_size.y - 1): 
			var e1 = grids[y][x]
			var e2 = grids[y+1][x]
			if e1.element_type == e2.element_type:
				if manager.is_valid_grid_pos(x, y-1):
					if is_same_type_neigbhour(x, y-1, e1):
						return true
				if manager.is_valid_grid_pos(x, y+2):
					if is_same_type_neigbhour(x, y+2, e2):
						return true
	#从左到右，检测非邻近相同两个元素横排的情况
	for y in range(map_size.y):
		for x in range(map_size.x - 2):
			var e1 = manager.get_elements_in_grids(x, y)
			var e2 = manager.get_elements_in_grids(x+1, y)
			var e3 = manager.get_elements_in_grids(x+2, y)
			if e1.element_type == e3.element_type:
				if e1.element_type != e2.element_type:
					if is_same_type_neigbhour(x+1, y, e1, e3):
						return true
	#从上到下，检测非邻近两个相同元素排列的情况
	for x in range(map_size.x):
		for y in range(map_size.y - 2):
			var e1 = manager.get_elements_in_grids(x, y)
			var e2 = manager.get_elements_in_grids(x, y+1)
			var e3 = manager.get_elements_in_grids(x, y+2)
			if e1.element_type == e3.element_type:
				if e1.element_type != e2.element_type:
					if is_same_type_neigbhour(x, y+1, e1, e3):
						return true
	return false

#检测指定栅格地图坐标的临近节点是否和指定元素的类型相同
func is_same_type_neigbhour(x:int,y:int,ignore_element1, ignore_element2=null):
	var dirs = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]
	var check_type = ignore_element1.element_type
	for dir in dirs:
		var pos = Vector2(x, y) + dir
		if not manager.is_valid_grid_pos(pos.x, pos.y):
			continue
		if pos == Vector2(ignore_element1.x, ignore_element1.y):
			continue
		if ignore_element2:
			if pos == Vector2(ignore_element2.x, ignore_element2.y):
				continue
		var e = manager.get_elements_in_grids(pos.x, pos.y)
		if e.element_type == check_type:
			return true
	return false

#清空栅格地图里的所有元素
func clear_map():
	for rows in range(map_size.y-1, -1, -1):
		for index_x in range(map_size.x-1, -1, -1):
			var e = grids[rows][index_x]
			match_elements.append(e)

