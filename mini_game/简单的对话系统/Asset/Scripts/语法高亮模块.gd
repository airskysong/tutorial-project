extends Node

var example = "var test = 1"

func _ready():
	check_key_word(example)
	

func check_key_word(line:String):
	var key_words = [
		"var",
		"func",
		"export"
	]
	for key_word in key_words:
		if key_word in line:
			print(key_word)
			return true

func get_statement_after_equal(line:String):
	if "=" in line:
		var index = line.find("=", 0)
		var right = line.right(index + 1).dedent()
		
	return false
