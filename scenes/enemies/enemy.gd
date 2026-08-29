extends CharacterBody2D

const SPEED := 55.0
const GRAVITY := 900.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var edge_check: RayCast2D = $EdgeCheck
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var dir := -1
var active := false
var stomped := false

func _ready() -> void:
	add_to_group("enemy")
	notifier.screen_entered.connect(func() -> void: active = true)
	notifier.screen_exited.connect(func() -> void: active = false)
	edge_check.target_position = Vector2(dir * 10.0, 16.0)
	anim.play("walk")

func _physics_process(delta: float) -> void:
	if stomped or not active:
		return
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, 520.0)
	velocity.x = dir * SPEED
	move_and_slide()
	if is_on_wall():
		_flip()
	elif is_on_floor():
		edge_check.force_raycast_update()
		if not edge_check.is_colliding():
			_flip()

func _flip() -> void:
	dir *= -1
	anim.flip_h = dir > 0
	edge_check.target_position = Vector2(dir * 10.0, 16.0)

func stomp() -> void:
	if stomped:
		return
	stomped = true
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	anim.scale = Vector2(1.0, 0.35)
	anim.offset.y = 12.0
	var puff: CPUParticles2D = get_node_or_null("Puff")
	if puff != null:
		puff.restart()
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(queue_free)
