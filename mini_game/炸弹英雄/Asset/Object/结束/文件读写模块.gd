extends Node

var high_score : int 

var data_path = "user://save_data.dat"
var datas = {"high_score": high_score}
var file := File.new()

func read():
	if file.file_exists(data_path):
		file.open(data_path, File.READ)
		var json_data = parse_json(file.get_line())
		high_score = json_data["high_score"]
		file.close()
	else:
		return

func write(highscore:int):
	read()
	if highscore > high_score:
		file.open(data_path, File.WRITE)
		datas["high_score"] = highscore
		var write_data = to_json(datas)
		file.store_string(write_data)
		file.close()
