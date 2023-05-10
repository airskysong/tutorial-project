extends module

signal disposed_elements(type)

var grids = []
var match_elements = []
var finish : bool = false

onready var tween := $Tween
onready var timer = $Timer
onready var next_module = load("res://Assets/Modules/主场景/生成模块.tscn") 

func init(_manager):
	manager = _manager
	grids = manager.grids
	match_elements = manager.match_elements
	self.connect("disposed_elements", manager, "on_disposed_elements")
	
func begin_handle():
	.begin_handle()
#	disponse_all_match()
	timer.start(0.1)
	yield(timer, "timeout")
	yield(disponse_all_match(), "completed")
	go_to_next_module(next_module)


func end_handle():
	.end_handle()

#消除所有符合三消的元素，清空匹配数组
func disponse_all_match():
	if match_elements.size() == 0:
		return
	var check = match_elements.size() < grids[0].size() * grids.size()

	for m in match_elements:
		if check:
			m.set_forcus()
#			m.call_deferred("set_forcus")
		else:
			m.set_all_forcus()
#			m.call_deferred("set_all_forcus")
	var multiplus = 1
	#轮次消除匹配的元素，通过修改动画的方法实现加速度消除
	for m in match_elements:
#		dispose_elements(m)
		multiplus += 0.3
		m.set_anim_speed(multiplus)
		yield(dispose_elements(m), "completed")
	match_elements.clear()

#消除单个元素，触发效果并发射信号
func dispose_elements(element:Node2D):
	grids[element.y][element.x] = null
	var type = element.element_type
	yield(element.dispose(), "completed")
	emit_signal("disposed_elements", type)
