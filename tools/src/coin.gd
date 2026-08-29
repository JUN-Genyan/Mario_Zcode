extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var pop := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if pop:
		anim.play("spin")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_node("/root/GameManager").add_coin()
		queue_free()

func pop_out() -> void:
	pop = true
	anim.play("spin")
	var tween := create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - 26.0, 0.18)
	tween.tween_callback(func() -> void: get_node("/root/GameManager").add_coin())
	tween.tween_interval(0.25)
	tween.tween_callback(queue_free)
