extends Area2D

# Called when the node enters the scene for the first time.
func _ready():
	assert(connect("body_entered", self, "on_player_entered") == 0)
	
func on_player_entered(_body):
#	print(body.name)
	get_tree().call_group("pickup_listeners", "on_pickup", self)
	queue_free()
