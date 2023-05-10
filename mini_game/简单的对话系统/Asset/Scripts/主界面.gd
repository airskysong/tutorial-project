extends Node2D

var content1 = """填写完 BBCode 的“Text”属性后，
你可以看到普通的“Text”属性变成了不带 BBCode 的版本。
这个文本属性会随 BBCode 属性更新，但你不能去编辑，
否则就会丢失 BBCode 标记。所有修改都必须在 BBCode 参数里完成。"""
var content2 = """填写完 BBCode 的“Text”属性后，
你可以看到普通的“Text”属性变成了不带 BBCode 的版本。
这个文本属性会随 BBCode 属性更新，但你不能去编辑，
否则就会丢失 BBCode 标记。所有修改都必须在 BBCode 参数里完成。"""


var content_length

onready var message := $"CanvasLayer/Control/文本"
onready var another := $"CanvasLayer/Control/文本2"
onready var tween := $"CanvasLayer/Control/Tween"

func _ready():
	message.text = content1
	another.bbcode_enabled = true
	another.bbcode_text = insert_bbcode("BBCode", content2)
	show_msg()
	

func _input(event):
	if event is InputEventScreenTouch and event.is_pressed:
		pass
		

func show_msg():
	tween.interpolate_property(message, "percent_visible",
	0, 1, 10, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
	tween.interpolate_property(another, "percent_visible",
	0, 1, 10, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	pass

func insert_bbcode(keyword:String, content:String):
	var f = "[fade start=0 length=4][/fade] "
	var i = "[rainbow freq=0.2 sat=10 val=20][/rainbow]"
	var c ="[code][/code]"
	var new_word = c.insert(c.find("]", 0)+1, keyword)
	return content.replace(keyword, new_word)
	
