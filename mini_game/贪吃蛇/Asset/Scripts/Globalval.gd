extends Node

var score:int = 0
var high_score:int = 0

func record_score():
	if high_score < score:
		high_score = score
		score = 0
