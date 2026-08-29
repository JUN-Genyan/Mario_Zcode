extends Area2D

signal reached

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var confetti: CPUParticles2D = get_node_or_null("Confetti")
		if confetti != null:
			confetti.emitting = true
		reached.emit()
