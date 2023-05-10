extends ColorRect

export(Resource) var text_res

var key_words = [
	"onready",
	"extends",
	"var",
	"float",
	"true",
	"func"
]

onready var rich_lable = $RichTextLabel
onready var tween = $Tween


func _ready():
#	var bbcode1 = "[code][/code]"
#	var red_bbcode = "[color=#e15b5b][/color]"
#	var content = insert_content_to_bbcode(bbcode1, text_res.code1)
#	for keyword in key_words:
#		content = set_bbcode_to_key_word(red_bbcode, keyword, content)
#	rich_lable.bbcode_enabled = true
	var reg = RegEx.new()
	reg.compile("\\w[a-zA-z]+")
	var c : String = text_res.code1
	rich_lable.bbcode_text = c
	var result = []

	for classname in ClassDB.get_class_list():
		print(classname)
#	do_tween_show_content(5)
	
	
func set_bbcode_to_key_word(bbcode:String, keyword:String, content:String):
	var replaced_word = insert_content_to_bbcode(bbcode, keyword)
	return content.replace(keyword, replaced_word)


func insert_content_to_bbcode(bbcode:String, content:String):
	return bbcode.insert(bbcode.find_last("["), content)


func do_tween_show_content(duration:float):
	tween.interpolate_property(rich_lable, "percent_visible",
	0, 1, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	pass
