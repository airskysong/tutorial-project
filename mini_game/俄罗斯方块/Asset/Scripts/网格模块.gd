extends Node2D

export (Vector2) var grid_size = Vector2(10, 20)
export (Vector2) var map_size = Vector2(340, 680)

onready var bg := $"背景颜色"
var grids = {}
var step : float
var start_pos : Vector2

func _ready():
	step =  round(map_size.x / grid_size.x)
	bg.rect_min_size = map_size
	for row in range(grid_size.x):
		for column in range(grid_size.y):
			var index := Vector2(row, column)
			grids[index] = null
	

func get_start_pos_offset():
	return float(map_size.y )/ 2 * Vector2.UP + Vector2.ONE * step

func get_right_pos_offset(node : Node2D):
	var child = node.get_child(0)
	var offset : Vector2 = Vector2.ZERO
	if child:
		var pos_x = child.position.x
		var pos_y = child.position.y
		if int(abs(pos_x - 32)) % 64 != 0:
			offset.x = step * 0.5
		if int(abs(pos_y - 32)) % 64 != 0:
			offset.y = step * 0.5
#		print("pos:%s, %s"%[str(pos_x), str(pos_y)])
#	print(offset)
	return offset
#更新方块在节点地图中的数据，节点地图是一个键为有序Vector2代表格子位置的数据，
#值为各个格子对象的字典。
func update_grids_datas(tetri : Node2D):
	#遍历网格字典，将所有有关于tetri节点的子结点位置记录清除
	for pos_index in grids.keys():
		if grids[pos_index] and grids[pos_index].get_parent() == tetri:
			grids[pos_index] = null
	
	#重新记录tetri节点下的子结点记录至grid对应的位置中
	for child_node in tetri.get_children():
		var key = as_index(child_node.global_position)
		if grids.has(key):
			grids[key] = child_node


func as_index(pos : Vector2):
	start_pos = global_position - map_size / 2 + Vector2.ONE * step / 2
	var pos_x = round((pos.x - start_pos.x) / step)
	var pos_y = round((pos.y - start_pos.y) / step)
	return Vector2(pos_x, pos_y)

func is_inside_Border(grid_pos:Vector2):
	return  grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y < grid_size.y

#检测当前方块的移动是否符合规则(1在范围内2移动的位置没有其它方块)
func is_valid_grid_pos(node:Node2D):
	for n in node.get_children():
		var grid_pos = as_index(n.global_position)
		if not is_inside_Border(grid_pos):
			return false
		if grids.has(grid_pos) and grids[grid_pos] != null and grids[grid_pos].get_parent()!=node:
			return false
	return true
			
func is_row_full(var column : int):
	var count:int = 0
	for row in range(grid_size.x):
		if grids[Vector2(row, column)]!=null:
			count += 1
			if count == grid_size.x:
				return true
	return false

func delete_row(var column : int):
	for row in range(grid_size.x):
		var node = grids[Vector2(row, column)]
		node.queue_free()
		grids[Vector2(row, column)] = null

func fall_row(var column:int):
	for row in range(grid_size.x):
		var node = grids[Vector2(row, column - 1)]
		if node:
			node.global_position += Vector2(0, step) 
			grids[Vector2(row, column)] = node
			grids[Vector2(row, column - 1)] = null

func fall_all_up_rows(var column:int):
	for y in range(column, 0, -1):
		fall_row(y)

func check_row_full_and_delete():
	var count : int = 0
	for column in range(grid_size.y):
		if is_row_full(column):
			delete_row(column)
			fall_all_up_rows(column)
			column -= 1
			count += 1
	return count
	
