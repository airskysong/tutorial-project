extends module

var grids = []
var match_elements = []

onready var next_module1 = load("res://Assets/Modules/主场景/消除模块.tscn")
onready var next_module2 = load("res://Assets/Modules/主场景/可行性检测模块.tscn")
#onready var timer = $Timer


func init(_manager):
	manager = _manager
	grids = manager.grids
	match_elements = manager.match_elements


func begin_handle():
	.begin_handle()
	if check_matched_elements():
		go_to_next_module(next_module1)
	else:
		go_to_next_module(next_module2)


func end_handle():
	.end_handle()

# 从上到下开始横排检测符合三消的元素，再从左到右一列一列检测符合三消的元素，把它们存储到数组中
func check_matched_elements():
	var is_matching : bool = false
	#检测横列
	for row in grids:
		for x in range(row.size() - 2):
			if row[x].element_type == row[x+1].element_type:
				if row[x+1].element_type==row[x+2].element_type:
					add_to_match_list(row[x])
					add_to_match_list(row[x+1])
					add_to_match_list(row[x+2])
					is_matching = true
	#检测竖列
	for x in range(grids[0].size()):
		for y in range(0, grids.size() - 2):
			if grids[y][x].element_type == grids[y+1][x].element_type:
				if grids[y+1][x].element_type == grids[y+2][x].element_type:
					add_to_match_list(grids[y][x])
					add_to_match_list(grids[y+1][x])
					add_to_match_list(grids[y+2][x])
					is_matching = true
	return is_matching

#把元素添加到数组中，元素不能重复添加
func add_to_match_list(element:Node2D):
	if match_elements.has(element):
		return
	match_elements.append(element)


