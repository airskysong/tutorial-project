extends module

var grid_size
var grids = []
var selected_elements
var can_touch : bool = false
var match_module

onready var tween = $Tween
onready var next_module = load("res://Assets/Modules/主场景/匹配检测模块.tscn")

func _ready():
	match_module = next_module.instance()


func init(var _manager):
	manager = _manager
	grid_size = manager.grid_size
	grids = manager.grids
	match_module.init(manager)
	
	
func begin_handle():
	.begin_handle()
	can_touch = true


func end_handle():
	.end_handle()
	can_touch = false
	
#输入处理函数，根据屏幕触点位置判断是否点击了栅格中的元素，再进行对应的判断	
func touch_grid_elements(pos:Vector2):
	var x_pos = (pos.x - manager.global_position.x) / grid_size
	var y_pos = (pos.y - manager.global_position.y) / grid_size
	var element = manager.get_elements_in_grids(x_pos, y_pos)
	#点击了栅格中的元素
	if element:
		#之前未选择元素
		if not selected_elements:
			element.is_selecting = true
			selected_elements = element
		else:
			#之前选择了元素：进行临近检测后交换元素位置、再进行三消检测消除，
			#匹配不上就回退原来两个元素的位置
			selected_elements.is_selecting = false
			if is_neigbhour_element(element, selected_elements):
				yield(exchange_two_elements(element, selected_elements), "completed")
				if not match_module.check_matched_elements():
					yield(exchange_two_elements(element, selected_elements), "completed")
				else:
					go_to_next_module(next_module)
			selected_elements = null

#Godot内置的输入处理
func _input(event):
	if not can_touch:
		return 
	if event is InputEventScreenTouch and event.is_pressed():
		touch_grid_elements(event.position)

#交换两个元素的位置
func exchange_two_elements(one:Node2D, another:Node2D):
	#使用常量存储将用于交换的数据
	var temp_x = one.x
	var temp_y = one.y
	
	var pos1 = manager.get_position_by_grids(another.x, another.y)
	one.update_x_and_y(another.x, another.y)
	grids[another.y][another.x] = one
	
	var pos2 = manager.get_position_by_grids(temp_x, temp_y)
	another.update_x_and_y(temp_x, temp_y)
	grids[temp_y][temp_x] = another
	#使用tween进行补间位移
	tween.interpolate_property(one, "global_position", one.global_position, pos1, 
	0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(another, "global_position", another.global_position, 
	pos2, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)	
	tween.start()
	yield(tween, "tween_completed")
	
#检测两个元素是不是邻近的元素
func is_neigbhour_element(one:Node2D, another:Node2D):
	var row = abs(one.x - another.x)
	var column = abs(one.y - another.y)
	if column == 1 and row == 0:
		return true
	elif row == 1 and column == 0:
		return true
	return  false
