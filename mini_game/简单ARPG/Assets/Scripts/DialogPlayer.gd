extends CanvasLayer

export(String, FILE, "*.json")var file_name
export(float) var interval = 1.0

var dialogAsset
var dialog_index = 0
var is_active = false

onready var character_lab = $Control/MarginContainer/NinePatchRect/CharacterName
onready var dialog_lab = $Control/MarginContainer/NinePatchRect/Dialog
onready var timer = $Control/MarginContainer/NinePatchRect/Timer
onready var tween = $Control/MarginContainer/NinePatchRect/Tween


func _ready():
	init(file_name)

	hide()


func _input(event):
	if is_active and event.is_action_pressed("ui_accept"):
		if visible == true:
			if tween.is_active():
				tween.seek(interval)
				return
			next_dialog()
		get_tree().set_input_as_handled()


func init(json_file_path):
	var file = File.new()
	if file.file_exists(json_file_path):
		file.open(json_file_path, File.READ)
		var content = file.get_as_text()
		dialogAsset = parse_json(content)
		file.close()

func show_dialog():
	get_tree().paused = true
	show()
	is_active = true
	next_dialog()
	
func next_dialog():
	if dialog_index > dialogAsset.size() - 1:
		hide()
		is_active = false
		get_tree().paused = false
		dialog_index = 0
		return
	character_lab.text = dialogAsset[dialog_index]["name"]
	dialog_lab.text = dialogAsset[dialog_index]["content"]
	do_tween_show_dialog()
	dialog_index += 1


func do_tween_show_dialog():
	tween.interpolate_property(dialog_lab, "percent_visible",
	 0, 1.0, interval,Tween.TRANS_QUAD,Tween.EASE_IN)
	tween.start()

