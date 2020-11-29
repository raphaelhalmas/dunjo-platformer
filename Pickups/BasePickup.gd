extends Area2D

export(bool) var anim_random_start = false

# Called when the node enters the scene for the first time.
func _ready():
	assert(connect("body_entered", self, "_on_player_entered") == 0)
	
	if anim_random_start:
		$Animation.advance($Animation.current_animation_length * randf())
	
func _on_player_entered(_body):
#	print(body.name)
	get_tree().call_group("game", "_on_pickup", self)
	queue_free()
