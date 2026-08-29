extends CanvasLayer

@onready var panel: Control = $Panel

var _paused := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_set_paused(not _paused)
		return
	if not _paused:
		return
	if Input.is_action_just_pressed("jump"):
		_set_paused(false)
	elif Input.is_action_just_pressed("restart"):
		_set_paused(false)
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("quit_game"):
		get_tree().quit()

func _set_paused(value: bool) -> void:
	_paused = value
	panel.visible = value
	get_tree().paused = value
