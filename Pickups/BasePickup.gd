extends Area2D

# Called when the node enters the scene for the first time.
func _ready():
	assert(connect("body_entered", self, "_on_player_entered") == 0)
	
func _on_player_entered(_body):
#	print(body.name)
	get_tree().call_group("game", "_on_pickup", self)
	queue_free()
