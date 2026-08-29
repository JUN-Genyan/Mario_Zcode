extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var score_label: Label = $HUD/Overlay/ScoreLabel
@onready var coin_label: Label = $HUD/Overlay/CoinLabel
@onready var lives_label: Label = $HUD/Overlay/LivesLabel
@onready var message_label: Label = $HUD/Overlay/MessageLabel

var _over := false

func _ready() -> void:
	var gm: Node = get_node("/root/GameManager")
	gm.reset_run()
	gm.score_changed.connect(func(value: int) -> void: score_label.text = "SCORE %06d" % value)
	gm.coins_changed.connect(func(value: int) -> void: coin_label.text = "COINS %02d" % value)
	gm.lives_changed.connect(func(value: int) -> void: lives_label.text = "LIVES %d" % value)
	gm.emit_changes()
	player.died.connect(_on_player_died)
	$Flag.reached.connect(_on_flag_reached)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_player_died() -> void:
	var gm: Node = get_node("/root/GameManager")
	if gm.lose_life():
		_over = true
		message_label.text = "GAME OVER"
		message_label.show()
		var timer := get_tree().create_timer(1.6)
		timer.timeout.connect(_back_to_title)
	else:
		player.respawn()

func _on_flag_reached() -> void:
	if _over:
		return
	get_node("/root/GameManager").level_completed = true
	player.win()
	message_label.text = "LEVEL COMPLETE!"
	message_label.show()
	var timer := get_tree().create_timer(2.5)
	timer.timeout.connect(_back_to_title)

func _back_to_title() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/title.tscn")
