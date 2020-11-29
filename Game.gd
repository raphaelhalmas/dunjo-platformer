extends Node2D

const LVL_PATH = "res://Levels/Level%d.tscn"

var _level_number:int = 1

func _ready():
	add_to_group("game")
	call_deferred("init") 

func init():
#	add_to_group("pickup_listeners")
	load_level(_level_number)
	
func load_level(level_number:int):
	var root = get_tree().root
	if root.has_node("Level1"):
		var node = root.get_node("Level1")
		root.remove_child(node)
		node.queue_free()
		
	#TODO: Check if level exists 
	var level = load(LVL_PATH % level_number).instance()
	root.add_child(level)
	return true

# Game group functions
func _on_next_level():
	_level_number += 1
	load_level(_level_number)

# The game gets notified anytime one of those items is picked up
func _on_pickup(item):
#	print(item.name)
	if item.name == "Key":
		get_tree().call_group("triggerable", "trigger", "Door")
		
func _computer_on():
	print("Computer on")
