extends CharacterBody2D

signal died

const SPEED := 167.0
const ACCEL := 1400.0
const FRICTION := 1600.0
const GRAVITY := 950.0
const JUMP_VELOCITY := -340.0
const MAX_FALL := 540.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.12

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var big := false
var dead := false
var facing := 1
var coyote := 0.0
var jump_buffer := 0.0
var invincible := 0.0
var spawn_pos := Vector2.ZERO
var _prev_floor := false

func _ready() -> void:
	add_to_group("player")
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	anim.play("idle")
	spawn_pos = global_position

func _physics_process(delta: float) -> void:
	if dead:
		return
	var move := Input.get_axis("move_left", "move_right")
	if move != 0.0:
		facing = 1 if move > 0 else -1
		anim.flip_h = facing < 0
	coyote = COYOTE_TIME if is_on_floor() else maxf(coyote - delta, 0.0)
	jump_buffer = JUMP_BUFFER if Input.is_action_just_pressed("jump") else maxf(jump_buffer - delta, 0.0)
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.45
	if move != 0.0:
		velocity.x = move_toward(velocity.x, move * SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	if jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		coyote = 0.0
	if Input.is_action_just_pressed("down"):
		_drop_platform()
	var was_rising := velocity.y < 0.0
	move_and_slide()
	if was_rising and is_on_ceiling():
		for i in get_slide_collision_count():
			var col := get_slide_collision(i)
			var body := col.get_collider()
			if body is StaticBody2D and body.is_in_group("blocks"):
				body.bump()
				break
	_update_animation()
	invincible = maxf(invincible - delta, 0.0)
	if global_position.y > 1100.0:
		die()

func _update_animation() -> void:
	if is_on_floor():
		if _prev_floor and absf(velocity.x) > 10.0:
			anim.play("run")
		elif not _prev_floor:
			anim.play("run" if absf(velocity.x) > 10.0 else "idle")
		else:
			anim.play("idle")
	elif velocity.y < 0.0:
		anim.play("jump")
	else:
		anim.play("fall")
	_prev_floor = is_on_floor()

func _drop_platform() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var body := col.get_collider()
		if body is StaticBody2D and body.is_in_group("oneway"):
			body.disable_for(0.25)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if dead or not body.is_in_group("enemy"):
		return
	if velocity.y > 0.0 and global_position.y < body.global_position.y - 6.0:
		velocity.y = JUMP_VELOCITY * 0.62
		body.stomp()
		get_node("/root/GameManager").add_score(100)
		get_node("/root/GameManager").play_sfx("stomp")
	else:
		hurt()

func power_up() -> void:
	set_big(true)
	get_node("/root/GameManager").add_score(200)
	get_node("/root/GameManager").play_sfx("power")

func set_big(value: bool) -> void:
	big = value
	var rect: RectangleShape2D = collision_shape.shape
	rect.size = Vector2(12, 30) if big else Vector2(10, 18)
	anim.scale = Vector2(1.3, 1.3) if big else Vector2.ONE

func hurt() -> void:
	if invincible > 0.0:
		return
	if big:
		set_big(false)
		invincible = 1.4
		get_node("/root/GameManager").play_sfx("hurt")
	else:
		die()

func die() -> void:
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	hide()
	get_node("/root/GameManager").play_sfx("die")
	died.emit()

func respawn() -> void:
	dead = false
	global_position = spawn_pos
	velocity = Vector2.ZERO
	show()

func win() -> void:
	dead = true
	velocity = Vector2.ZERO
	anim.play("idle")
