extends Node2D

@export var m_rooms_num : int

#引用四个不同开口的房间模型，a为起始，d为末尾
@onready var room_a = load("res://Asset/Scenes/Room/room_a.tscn")
@onready var room_b = load("res://Asset/Scenes/Room/room_b.tscn")
@onready var room_c = load("res://Asset/Scenes/Room/room_c.tscn")
@onready var room_d = load("res://Asset/Scenes/Room/room_d.tscn")

#房间的通道模型
@onready var room_link = load("res://Asset/Scenes/Room/linkway.tscn")
@onready var spawn_point = $environment
#不同类型房间通道之间的偏移为
var m_offset_a = Vector2(80,0)
var m_offset_b = Vector2(95,0)
var m_offset_c = Vector2(110,0)
#用一个数组存储随机生成的房间模型
var rand_rooms = []


func _ready():
	randomize()
	rand_rooms.append(room_b)
	rand_rooms.append(room_c)
	create_rooms(m_rooms_num)
	
#根据给定的房间数量生成一排横向的地牢地形房间
func create_rooms(num:int):
	if num < 2:
		num = 0
	else:
		num = num - 2
	
	var last = m_offset_a
	set_room(room_a, Vector2.ZERO, spawn_point)
	set_room(room_link, last, spawn_point)
	
	for _x in range(0, num):
		var new_room = rand_rooms[randi_range(0, 1)]
		var new_pos
		if new_room == room_b:
			new_pos = last + m_offset_b
			last = new_pos + m_offset_b
		else:
			new_pos = last + m_offset_c
			last = new_pos + m_offset_c
		set_room(new_room, new_pos, spawn_point)
		set_room(room_link, last, spawn_point)
	set_room(room_d, last + m_offset_a, spawn_point)	

#生成模型并放置到对应的位置,位置为父节点的相对位置
func set_room(room:PackedScene, pos:Vector2, parent):
	var temp = room.instantiate()
	parent.add_child(temp)
	temp.position = pos
	return temp
	
