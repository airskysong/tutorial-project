extends Node
class_name module


var manager
var process_begin = false
var cost_time 


func init(var _manager):
	manager = _manager


func module_update():
	if not process_begin:
		begin_handle()
		process_begin = true
	module_handle()
	
	
func module_handle():
#	print("%s模块处理中"%str(self))
	pass


func begin_handle():
#	print("开始处理%s!"%str(self))
#	cost_time = Time.get_ticks_msec()
	pass

func end_handle():
	process_begin = true
#	cost_time = Time.get_ticks_msec() - cost_time
#	print("%s处理完成! 耗时%s"%[str(self),str(cost_time/float(1000))])
	call_deferred("queue_free")


func go_to_next_module(var next_module):
	if manager:
		manager.set_module(next_module)

#func module_handle():
# .module_handle()
#  pass
#func begin_handle():
# .module_handle()
#  pass
#func end_handle():
# .module_handle()
#  pass
