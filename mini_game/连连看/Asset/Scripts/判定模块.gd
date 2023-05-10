extends Node
var grid_data = {}
var map_size : Vector2
var max_ranges = 1000
var points_pos = []

func init(gridManager):
	grid_data = gridManager.grid_data
	map_size = grid_data.keys()[-1]


func check_lines(pos1:Vector2, pos2:Vector2):
	points_pos.clear()
	if is_valid_line_x(pos1, pos2) or is_valid_line_y(pos1, pos2):
		add_points(pos1)
		add_points(pos2)
#		print(points_pos)
		return true
	return false


func check_one_corner(pos1:Vector2, pos2:Vector2):
	points_pos.clear()
	if is_valid_on_corner(pos1, pos2):
#		print(points_pos)
		return true
	return false


func check_two_corner(pos1:Vector2, pos2:Vector2):
	points_pos.clear()
	if is_valid_on_two_corner(pos1, pos2):
#		print(points_pos)
		return true
	return false

#x方向单行检测，判断两个坐标之间的栅格数据是否为空
func is_valid_line_x(pos1:Vector2, pos2:Vector2):
	if pos1.y != pos2.y:
		return false
	if abs(pos1.x - pos2.x) > 1:
		var step = int(sign(pos2.x - pos1.x))
		var start = int(pos1.x) + step
		var end = int(pos2.x)
		for x in range(start, end, step):
			var element = grid_data[Vector2(x, pos1.y)]
			if element:
				return false
	return true

#y方向单行检测，判断两个坐标之间的栅格数据是否为空
func is_valid_line_y(pos1:Vector2, pos2:Vector2):
	if pos1.x != pos2.x:
		return false
	if abs(pos1.y - pos2.y) > 1:
		var step = int(sign(pos2.y - pos1.y))
		var start = int(pos1.y) + step
		var end = int(pos2.y)
		for y in range(start, end, step):
			var element = grid_data[Vector2(pos1.x, y)]
			if element:
				return false
	return true

#二折
func is_valid_on_corner(pos1:Vector2, pos2:Vector2):
	#横向
	var corner1 = Vector2(pos2.x, pos1.y)
	#竖向
	var corner2 = Vector2(pos1.x, pos2.y)
	if not grid_data[corner1] and is_valid_line_x(pos1, corner1):
		if is_valid_line_y(corner1, pos2):
			add_points(pos1)
			add_points(corner1)
			add_points(pos2)
			return true
	if not grid_data[corner2] and is_valid_line_y(pos1, corner2):
		if is_valid_line_x(corner2, pos2):
			add_points(pos1)
			add_points(corner2)
			add_points(pos2)
			return true
	return false

#三折
func is_valid_on_two_corner(pos1:Vector2, pos2:Vector2):
	var dirs = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]

	for dir in dirs:
		for _t in range(max_ranges):
			var new_pos = pos1 + dir * (_t + 1)
			if is_valid_pos(new_pos) and not grid_data[new_pos]:
				if is_valid_on_corner(new_pos, pos2):
					points_pos.insert(0, pos1)
					return true
			else:
				break
	return false


func is_valid_pos(pos:Vector2):
	return pos.x >= 0 and pos.x <= map_size.x and pos.y >= 0 and pos.y <= map_size.y


func add_points(pos:Vector2):
	if points_pos.has(pos):
		return
	else:
		points_pos.append(pos)
	
