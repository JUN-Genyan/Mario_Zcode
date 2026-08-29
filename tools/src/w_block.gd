@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var body: StaticBody2D = StaticBody2D.new()
		body.name = "Block"
		ctx.set_scene_root(body)
		root = body
	var block: StaticBody2D = root as StaticBody2D
	if block == null:
		ctx.error("root is not StaticBody2D")
		return
	block.collision_layer = 1
	block.collision_mask = 0
	block.script = load("res://scenes/items/block.gd")

	var col: CollisionShape2D = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(18, 18)
	col.shape = shape
	block.add_child(col)
	ctx.own(col)

	var atlas: Texture2D = load("res://assets/pixel-platformer/Tilemap/tilemap.png")
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "Sprite2D"
	var tex: AtlasTexture = AtlasTexture.new()
	tex.atlas = atlas
	tex.region = Rect2(152, 19, 18, 18)
	sprite.texture = tex
	block.add_child(sprite)
	ctx.own(sprite)

	var used: AtlasTexture = AtlasTexture.new()
	used.atlas = atlas
	used.region = Rect2(171, 19, 18, 18)
	block.set("used_texture", used)
	block.set("content", "coin")

	ctx.log("block scene built: static body + question sprite + used texture")
	ctx.mark_modified()
