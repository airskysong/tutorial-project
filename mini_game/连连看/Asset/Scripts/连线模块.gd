extends Node

export(float) var life_time = 0.1

var line_points = []
var duration = 0.1
var line : Line2D
var points_index = 1
var gridManager

onready var tween := $Tween

func init(_gridManager):
	gridManager = _gridManager

func draw_line(point1:Vector2, point2:Vector2, point3 = null,
point4 = null):

	clear_line()
	line = Line2D.new()
	line.default_color = Color.red
	line.width = 5
	add_child(line)
	point1 = get_pos(point1)
	point2 = get_pos(point2)
	
	line_points.append(point1)
	line_points.append(point2)
	if point3:
		point3 =get_pos(point3)
		line_points.append(point3)
		if point4:
			point4 = get_pos(point4)
			line_points.append(point4)
	yield(do_tween(), "completed")
	fade()
	
func clear_line():
	points_index = 1
	line_points.clear()
	line = null


func do_tween():
	var points_size = line_points.size()
	if points_size < 2:
		return
		
	line.add_point(line_points[0], 0)
	for index in range(points_size-1):
		var from : Vector2 = line_points[index]
		var to : Vector2 = line_points[index+1]
		line.add_point(to, index + 1)
		set_line_pos(from)	
		tween.interpolate_method(self, "set_line_pos", from, to,
		duration / float(points_size),
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_all_completed")
		points_index += 1


func fade():
	tween.interpolate_method(self, "set_line_alpha", 1.0, 0.2, life_time,
	Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_all_completed")
	line.queue_free()


func set_line_alpha(value:float):
	line.modulate.a = value

func set_line_pos(to:Vector2):
	line.set_point_position(points_index, to)

func get_pos(pos:Vector2):
	 return gridManager.get_pos_by_coordinate(pos) + gridManager.global_position
