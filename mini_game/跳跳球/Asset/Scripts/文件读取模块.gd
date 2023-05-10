extends Node

var high_score :int
var data = {"highscore" : high_score}
var file = File.new()
var file_path = "res://scores.dat"

func read():
	if file.file_exists(file_path):
		var result = file.open(file_path, File.READ)
		if result != OK:
			file.close()
			print("不存在文件 %s"%file_path)
			return
		var fileData = parse_json(file.get_line())
		high_score = fileData["highscore"]
		file.close()

func write(score):
	read()
	if score > high_score:
		high_score = score
	data["highscore"] = high_score
	file.open(file_path, File.WRITE)
	file.store_line(to_json(data))
	file.close()
