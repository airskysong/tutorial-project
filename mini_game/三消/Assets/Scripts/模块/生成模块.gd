extends module

var map_size : Vector2
var grids = []

onready var timer = $Timer
onready var tween = $Tween

onready var element_pref = load("res://Assets/Modules/主场景/元素.tscn")
onready var input_module = load("res://Assets/Modules/主场景/控制输入模块.tscn")
onready var match_module = load("res://Assets/Modules/主场景/匹配检测模块.tscn")


func init(var _manager):
	manager = _manager
	grids = manager.grids
	map_size = manager.map_size


func begin_handle():
	.begin_handle()
	timer.start(0.1)
	yield(timer, "timeout")
	yield(fill_column_blank(), "completed")
	go_to_next_module(match_module)

#从底部开始，在最上行生成元素后，竖直填充空格
func fill_column_blank():
#		timer.start(0.1)
#		yield(timer, "timeout")
		var offset_y = []
		for _x in range(map_size.x):
			offset_y.append(0)
		for y in range(map_size.y - 1, -1, -1):
			for x in range(map_size.x):
				if grids[y+offset_y[x]][x] == null:
					for column in range(y+offset_y[x], 0, -1):
						fall_above_elements(x, column)
					create_new_element(x, 0)
					offset_y[x] += 1
			timer.start(0.1)
			yield(timer, "timeout")

#输入栅格位置创建并返回一个对应该位置的元素
func create_new_element(x, y):
	var pos = manager.get_position_by_grids(x, y)
	var e = element_pref.instance()
	manager.add_child(e)
	e.scale *= 0.95
	e.update_datas(x, y, pos)
	grids[y][x] = e
	
#指定栅格的位置，位置上面的元素掉落到这个位置中
func fall_above_elements(x:int, y:int):
	var above = grids[y-1][x]
	if above:
		grids[y][x] = above
		grids[y-1][x] = null
		above.update_x_and_y(x, y)
		var pos2 = manager.get_position_by_grids(x, y)
		var pos1 = manager.get_position_by_grids(x, y-1)
		tween.interpolate_property(above, "global_position", 
		pos1, pos2, 0.1, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tween.start()
