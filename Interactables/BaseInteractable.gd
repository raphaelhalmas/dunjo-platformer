extends Area2D

const InteractType = preload("res://Commons/GlobalEnums.gd").InteractType

export(int) var type = InteractType.NONE

func _on_Interactable_body_entered(body):
	if body.has_method("on_interact_entered"):
		body.on_interact_entered(global_position, type)

func _on_Interactable_body_exited(body):
	if body.has_method("on_interact_exited"):
		body.on_interact_exited(global_position, type)
