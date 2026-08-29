extends StaticBody2D

func _ready() -> void:
	add_to_group("oneway")

func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		return
	var can_land := player.velocity.y >= 0.0 and player.global_position.y < global_position.y - 8.0
	collision_layer = 4 if can_land else 0

func disable_for(seconds: float) -> void:
	collision_layer = 0
	var timer := get_tree().create_timer(seconds)
	timer.timeout.connect(func() -> void: collision_layer = 4)
