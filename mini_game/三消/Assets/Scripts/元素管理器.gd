extends Node2D

signal disposed(type)

export(Vector2) var map_size = Vector2(5, 5) 
export(int) var grid_size = 64

var map_width : int
var map_height : int
var match_elements = []
var grids = []
var selected_elements : Node2D = null
var can_touch : bool = true

var current_module : module = null

onready var bg := $"背景"
onready var creater_module = load("res://Assets/Modules/主场景/生成模块.tscn")


func _ready():
	map_width = map_size.x * grid_size
	map_height = map_size.y * grid_size
	bg.rect_min_size = Vector2(map_width, map_height)
	set_all_map_to_center()
	init_map()
	set_module(creater_module)

#初始化栅格地图数据
func init_map():
	for _index_y in range(map_size.y):
		var row_elements = []
		for _index_x in range(map_size.x):
			row_elements.append(null)
		grids.append(row_elements)

# 设置状态模块
func set_module(var module):
	if current_module:
		current_module.end_handle()

	var new_module = module.instance()
	add_child(new_module)
	new_module.init(self)
	current_module = new_module as module
	current_module.module_update()
	

#输入栅格坐标返回对应位置的元素	
func get_elements_in_grids(x:int, y:int):
	if is_valid_grid_pos(x, y):
		return grids[y][x]
	return null

#输入栅格坐标返回实际的屏幕位置
func get_position_by_grids(x:int, y:int):
	var start : Vector2 = global_position + Vector2.ONE * grid_size * 0.5
	return Vector2(start.x + x * grid_size, start.y + y * grid_size)

#检查栅格坐标是否在栅格地图之内
func is_valid_grid_pos(x:int, y:int):
	return x >= 0 and x < map_size.x and y >=0 and y < map_size.y
	
# 将画面设置到屏幕中央
func set_all_map_to_center():
	var screen_size = get_viewport_rect().size
	var offset = Vector2(map_width * 0.5, map_height * 0.5)
	global_position  = screen_size / 2  - offset

func on_disposed_elements(var _type):
	emit_signal("disposed", _type)
