extends Control

@onready var prompt: Label = $Prompt

var _time := 0.0
var _starting := false

func _process(delta: float) -> void:
	_time += delta
	prompt.modulate.a = 0.55 + 0.45 * sin(_time * 4.0)
	if _starting:
		return
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		_starting = true
		get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	elif Input.is_action_just_pressed("pause"):
		get_tree().quit()
