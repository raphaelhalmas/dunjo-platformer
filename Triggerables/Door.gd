extends "res://Triggerables/BaseTriggerable.gd"

var is_open := false

func _on_triggered():
	if !is_open:
		$Animation.play("Open")
		is_open = true

func _on_player_entered(_body):
	if !is_open:
		return
	get_tree().call_group("game", "_on_next_level")
