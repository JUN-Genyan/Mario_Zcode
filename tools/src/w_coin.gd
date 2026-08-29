@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var area: Area2D = Area2D.new()
		area.name = "Coin"
		ctx.set_scene_root(area)
		root = area
	var coin: Area2D = root as Area2D
	if coin == null:
		ctx.error("root is not Area2D")
		return
	coin.collision_layer = 0
	coin.collision_mask = 2
	coin.script = load("res://scenes/items/coin.gd")

	var col: CollisionShape2D = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(16, 16)
	col.shape = shape
	coin.add_child(col)
	ctx.own(col)

	var atlas: Texture2D = load("res://assets/generated/coin_sheet.png")
	var frames: SpriteFrames = SpriteFrames.new()
	frames.add_animation("spin")
	frames.set_animation_speed("spin", 9.0)
	frames.set_animation_loop("spin", true)
	for rx: float in [0.0, 16.0, 32.0]:
		var tex: AtlasTexture = AtlasTexture.new()
		tex.atlas = atlas
		tex.region = Rect2(rx, 0.0, 16.0, 16.0)
		frames.add_frame("spin", tex)
	var anim: AnimatedSprite2D = AnimatedSprite2D.new()
	anim.name = "AnimatedSprite2D"
	anim.sprite_frames = frames
	anim.animation = &"spin"
	anim.autoplay = "spin"
	coin.add_child(anim)
	ctx.own(anim)

	ctx.log("coin scene built: pickup area + spinning sprite")
	ctx.mark_modified()
