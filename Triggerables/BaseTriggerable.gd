extends Area2D

export (String) var tag

# Called when the node enters the scene tree for the first time
func _ready():
#	We're gonna be able to trigger this little fella from other places
	add_to_group("triggerable")
	assert(connect("body_entered", self, "_on_player_entered") == 0)

func trigger(tag_name:String):
	if tag.length() == 0 || tag != tag_name:
		return
	_on_triggered()
	
# We'll get at least a warning when we get triggered 
# and we haven't overriden this method
func _on_triggered():
	print("Need implementation of _on_triggered() in file: %s" % filename)

func _on_player_entered(_body):
	print("Need implementation of on_player_entered() in file: %s" % filename)
