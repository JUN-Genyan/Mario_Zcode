@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var body: CharacterBody2D = CharacterBody2D.new()
		body.name = "Enemy"
		ctx.set_scene_root(body)
		root = body
	var enemy: CharacterBody2D = root as CharacterBody2D
	if enemy == null:
		ctx.error("root is not CharacterBody2D")
		return
	enemy.collision_layer = 8
	enemy.collision_mask = 1
	enemy.script = load("res://scenes/enemies/enemy.gd")

	var col: CollisionShape2D = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(14, 16)
	col.shape = shape
	enemy.add_child(col)
	ctx.own(col)

	var atlas: Texture2D = load("res://assets/pixel-platformer/Tilemap/tilemap-characters.png")
	var frames: SpriteFrames = SpriteFrames.new()
	frames.add_animation("walk")
	frames.set_animation_speed("walk", 6.0)
	frames.set_animation_loop("walk", true)
	for r: Vector2 in [Vector2(50, 25), Vector2(75, 25)]:
		var tex: AtlasTexture = AtlasTexture.new()
		tex.atlas = atlas
		tex.region = Rect2(r.x, r.y, 24.0, 24.0)
		frames.add_frame("walk", tex)
	var anim: AnimatedSprite2D = AnimatedSprite2D.new()
	anim.name = "AnimatedSprite2D"
	anim.sprite_frames = frames
	anim.animation = &"walk"
	enemy.add_child(anim)
	ctx.own(anim)

	var edge: RayCast2D = RayCast2D.new()
	edge.name = "EdgeCheck"
	enemy.add_child(edge)
	ctx.own(edge)

	var notifier: VisibleOnScreenNotifier2D = VisibleOnScreenNotifier2D.new()
	notifier.name = "VisibleOnScreenNotifier2D"
	enemy.add_child(notifier)
	ctx.own(notifier)

	var puff: CPUParticles2D = CPUParticles2D.new()
	puff.name = "Puff"
	puff.position = Vector2(0, -2)
	puff.emitting = false
	puff.amount = 10
	puff.one_shot = true
	puff.explosiveness = 1.0
	puff.lifetime = 0.45
	puff.direction = Vector2(0, -1)
	puff.spread = 75.0
	puff.gravity = Vector2(0, 260)
	puff.initial_velocity_min = 40.0
	puff.initial_velocity_max = 95.0
	puff.scale_amount_min = 1.0
	puff.scale_amount_max = 2.2
	puff.texture = _dot_texture()
	enemy.add_child(puff)
	ctx.own(puff)

	ctx.log("enemy scene built: patrol body + edge ray + notifier + stomp puff")
	ctx.mark_modified()

func _dot_texture() -> ImageTexture:
	var img: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(img)
