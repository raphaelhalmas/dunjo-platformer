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
	var old_level = get_current_level_node()

	if old_level != null:
		root.remove_child(old_level)
		old_level.queue_free()
		
	var resource = load(LVL_PATH % level_number)

	if resource != null:
		var level = resource.instance()
		root.add_child(level)
		return true
	else:
		print("%s does not exist! TODO: Win Game!" % [LVL_PATH % level_number])
		return false

# Game group functions
func _on_next_level():
	_level_number += 1
	load_level(_level_number)

# The game gets notified anytime one of those items is picked up
func _on_pickup(item):
#	print(item.name)
	if item.name == "Key":
		get_tree().call_group("triggerable", "trigger", "Door")
		
func get_current_level_node():
	var root = get_tree().root
	
	if root.has_node("Level"):
		return root.get_node("Level")
	return null
		
func _computer_on():
#	print("Computer on")
	var level = get_current_level_node()
	
	if level != null:		
		if !$GateOpening.playing:
			$GateOpening.play()
#			get_tree().paused = true
			yield(get_tree().create_timer(0.25), "timeout")
#			get_tree().paused = false
			level.replace_tiles(level.BLOCK, -1)




