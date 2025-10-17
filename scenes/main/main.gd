extends Node2D

##################################################
const FIREWORKS_SCENE: PackedScene = \
	preload("res://scenes/fireworks/fireworks.tscn")

##################################################
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_launch()

##################################################
func _launch() -> void:
	var fireworks_instance: Node2D = FIREWORKS_SCENE.instantiate()
	add_child(fireworks_instance)
	fireworks_instance.launch()
