extends Node2D

signal win
signal destroy_element(type)

export(Vector2) var grid_size = Vector2(10, 6)

var grid_data = {}
var element_list = []
var element_size = 64
var element_scale = 0.5
var can_touch = true
var selected_elements

onready var element_model = load("res://Asset/Objects/Main/元素.tscn")
onready var check_module = $"判定模块"
onready var line_module = $"连线模块"

func _ready():
	randomize()
	if (int(grid_size.x * grid_size.y)) % 2 != 0:
		print("总元素数量为奇数")
		return
	init_map()
	init_module()


func init_map():
	var count = 0
	var type = 0
	for y in range(grid_size.y + 2):
		for x in range(grid_size.x + 2):
			var pos = Vector2(x, y)
			grid_data[pos] = null
			if x!=0 and y!=0 and x!=grid_size.x+1 and y!=grid_size.y+1:
				create_elements(type)
				count = count + 1
				if count % 2 == 0:
					type = type + 1
	
	
	var new_list = set_random_group(element_list)
	for key in grid_data.keys():
		if key.x == 0 or key.y==0 or key.x == grid_size.x+1 or key.y == grid_size.y+1:
			continue
		var e = new_list.pop_front()
		var pos = get_pos_by_coordinate(key)
		e.set_pos(pos)
		e.set_coordinate(key)
		grid_data[key] = e


func init_module():
	check_module.init(self)
	line_module.init(self)


func create_elements(type:int):
	var e = element_model.instance()
	add_child(e)
	e.set_type(type)
	e.set_size(element_scale)
	element_list.append(e)


func set_random_group(array:Array):
	var new_array = array.duplicate(true)
	var result = []
	for _t in array.size():
		var rand_index = int(rand_range(0, new_array.size()))
		result.append(new_array.pop_at(rand_index))
	return result

#输入栅格坐标返回对应位置的元素	
func get_elements_in_grids(x:int, y:int):
	if is_valid_grid_pos(x, y):
		return grid_data[Vector2(x, y)]
	return null


func get_pos_by_coordinate(coordinate:Vector2):
	var pos = Vector2(
		element_size * element_scale * 0.5 + coordinate.x * element_size * element_scale,
		element_size * element_scale * 0.5 + coordinate.y * element_size * element_scale
		)
	return pos

#检查栅格坐标是否在栅格地图之内
func is_valid_grid_pos(x:int, y:int):
	return x >= 0 and x < grid_size.x + 2 and y >=0 and y < grid_size.y + 2

#输入处理函数，根据屏幕触点位置判断是否点击了栅格中的元素，再进行对应的判断	
func touch_grid_elements(pos:Vector2):
	var x_pos = (pos.x - global_position.x) / (element_size * element_scale)
	var y_pos = (pos.y - global_position.y) / (element_size * element_scale)
	var element = get_elements_in_grids(x_pos, y_pos)
	#点击了栅格中的元素
	if element:
		#之前未选择元素
		if not selected_elements:
			element.is_selecting = true
			selected_elements = element
		else:
			#之前选择元素
			#取消前一个元素的选择状态
			selected_elements.is_selecting = false
			#重复选择上一个元素，操作取消
			if selected_elements == element:
				selected_elements = null
				return
			#上一个元素与当前元素进行匹配，匹配成功后直接消除
			if check_elements(selected_elements, element):
				var e_type = selected_elements.element_type
				remove_element(selected_elements)
				remove_element(element)
				selected_elements = null
				emit_signal("destroy_element", e_type)
				if check_game_win():
					print("win")
				return
			#匹配失败后，记录当前的元素并标记选择状态
			selected_elements = element
			selected_elements.is_selecting = true
		pass

#Godot内置的输入处理
func _input(event):
	if not can_touch:
		return
	if event is InputEventScreenTouch and event.is_pressed():
		touch_grid_elements(event.position)


func check_elements(element1, element2):
	if element1.element_type == element2.element_type:
		var pos1 = element1.coordinate
		var pos2 = element2.coordinate
		if check_module.check_lines(pos1, pos2):
			line_module.draw_line(pos1, pos2)
			return true
		if check_module.check_one_corner(pos1, pos2):
			var points = check_module.points_pos
			line_module.draw_line(points[0], points[1], points[2])
			return true
		if check_module.check_two_corner(pos1, pos2):
			var points = check_module.points_pos
			line_module.draw_line(points[0], points[1], points[2], points[3])
			return true
	return false


func remove_element(var element):
	grid_data[element.coordinate] = null
	element.destroy()


func check_game_win():
	for key in grid_data.keys():
		if grid_data[key]:
			return false
	emit_signal("win")
	return true
