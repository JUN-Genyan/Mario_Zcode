@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var body: StaticBody2D = StaticBody2D.new()
		body.name = "Platform"
		ctx.set_scene_root(body)
		root = body
	var platform: StaticBody2D = root as StaticBody2D
	if platform == null:
		ctx.error("root is not StaticBody2D")
		return
	platform.collision_layer = 4
	platform.collision_mask = 0
	platform.script = load("res://scenes/objects/platform.gd")

	var col: CollisionShape2D = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(54, 8)
	col.shape = shape
	platform.add_child(col)
	ctx.own(col)

	var visual: ColorRect = ColorRect.new()
	visual.name = "Visual"
	visual.offset_left = -27.0
	visual.offset_top = -4.0
	visual.offset_right = 27.0
	visual.offset_bottom = 4.0
	visual.color = Color(0.35, 0.85, 0.45, 0.55)
	platform.add_child(visual)
	ctx.own(visual)

	ctx.log("platform scene built: one-way body + translucent visual")
	ctx.mark_modified()
