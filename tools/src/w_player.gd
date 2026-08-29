@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var body: CharacterBody2D = CharacterBody2D.new()
		body.name = "Player"
		ctx.set_scene_root(body)
		root = body
	var player: CharacterBody2D = root as CharacterBody2D
	if player == null:
		ctx.error("root is not CharacterBody2D")
		return
	player.collision_layer = 2
	player.collision_mask = 5
	player.script = load("res://scenes/player/player.gd")

	var col: CollisionShape2D = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(10, 18)
	col.shape = shape
	player.add_child(col)
	ctx.own(col)

	var atlas: Texture2D = load("res://assets/pixel-platformer/Tilemap/tilemap-characters.png")
	var frames: SpriteFrames = SpriteFrames.new()
	_add_anim(frames, "idle", atlas, [Vector2(0, 0)], 4.0)
	_add_anim(frames, "run", atlas, [Vector2(25, 0), Vector2(50, 0), Vector2(75, 0)], 10.0)
	_add_anim(frames, "jump", atlas, [Vector2(50, 0)], 1.0)
	_add_anim(frames, "fall", atlas, [Vector2(75, 0)], 1.0)
	var anim: AnimatedSprite2D = AnimatedSprite2D.new()
	anim.name = "AnimatedSprite2D"
	anim.sprite_frames = frames
	anim.animation = &"idle"
	player.add_child(anim)
	ctx.own(anim)

	var hurtbox: Area2D = Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 8
	player.add_child(hurtbox)
	ctx.own(hurtbox)
	var hcol: CollisionShape2D = CollisionShape2D.new()
	hcol.name = "HurtboxShape"
	var hshape: RectangleShape2D = RectangleShape2D.new()
	hshape.size = Vector2(12, 14)
	hcol.shape = hshape
	hcol.position = Vector2(0, -1)
	hurtbox.add_child(hcol)
	ctx.own(hcol)

	var cam: Camera2D = Camera2D.new()
	cam.name = "Camera2D"
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = 1080
	cam.limit_bottom = 540
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 6.0
	player.add_child(cam)
	ctx.own(cam)

	ctx.log("player scene built: collision + anim + hurtbox + camera")
	ctx.mark_modified()

func _add_anim(frames: SpriteFrames, anim_name: String, atlas: Texture2D, regions: Array, speed: float) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, speed)
	frames.set_animation_loop(anim_name, true)
	for r: Vector2 in regions:
		var tex: AtlasTexture = AtlasTexture.new()
		tex.atlas = atlas
		tex.region = Rect2(r.x, r.y, 24.0, 24.0)
		frames.add_frame(anim_name, tex)
