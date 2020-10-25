extends Node2D

const LVL_PATH = "res://Levels/Level%d.tscn"

var _level_number:int = 1

func init():
	add_to_group("pickup_listeners")
	load_level(_level_number)

func _ready():
	call_deferred("init") 
	
func load_level(level_number:int):
	var root = get_tree().root
	if root.has_node("BaseLevel"):
		root.remove_child($BaseLevel)
		
	#TODO: Check if level exists 
	var level = load(LVL_PATH % level_number).instance()
	root.add_child(level)
	return true

# The game gets notified anytime one of those items is picked up
func on_pickup(item):
	print(item.name)
