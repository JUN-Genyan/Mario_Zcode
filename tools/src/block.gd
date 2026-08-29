extends StaticBody2D

@export var content := "coin"
@export var used_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

var used := false

func _ready() -> void:
	add_to_group("blocks")

func bump() -> void:
	_bump_anim()
	if used:
		return
	used = true
	if content == "coin":
		_spawn_coin()
	elif content == "mushroom":
		_spawn_mushroom()
	if used_texture != null:
		sprite.texture = used_texture

func _bump_anim() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", -7.0, 0.08)
	tween.tween_property(sprite, "position:y", 0.0, 0.14)
	get_node("/root/GameManager").play_sfx("bump")

func _spawn_coin() -> void:
	var coin: Node2D = load("res://scenes/items/coin.tscn").instantiate()
	get_parent().add_child(coin)
	coin.global_position = global_position + Vector2(0, -12)
	coin.pop_out()

func _spawn_mushroom() -> void:
	var mushroom: Node2D = load("res://scenes/items/mushroom.tscn").instantiate()
	get_parent().add_child(mushroom)
	mushroom.start_rise(global_position + Vector2(0, -6))
