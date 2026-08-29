@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var area: Area2D = Area2D.new()
		area.name = "Flag"
		ctx.set_scene_root(area)
		root = area
	var flag: Area2D = root as Area2D
	if flag == null:
		ctx.error("root is not Area2D")
		return
	flag.collision_layer = 0
	flag.collision_mask = 2
	flag.script = load("res://scenes/objects/flag.gd")

	var col: CollisionShape2D = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(10, 250)
	col.shape = shape
	col.position = Vector2(0, -125)
	flag.add_child(col)
	ctx.own(col)

	var pole: Polygon2D = Polygon2D.new()
	pole.name = "Pole"
	pole.color = Color(0.85, 0.7, 0.25, 1.0)
	pole.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(2, 0), Vector2(2, 250), Vector2(-2, 250)])
	flag.add_child(pole)
	ctx.own(pole)

	var banner: Polygon2D = Polygon2D.new()
	banner.name = "Banner"
	banner.color = Color(0.2, 0.75, 0.35, 1.0)
	banner.polygon = PackedVector2Array([Vector2(2, -8), Vector2(44, -2), Vector2(2, 6)])
	flag.add_child(banner)
	ctx.own(banner)

	var confetti: CPUParticles2D = CPUParticles2D.new()
	confetti.name = "Confetti"
	confetti.position = Vector2(0, -240)
	confetti.emitting = false
	confetti.amount = 30
	confetti.one_shot = true
	confetti.explosiveness = 0.85
	confetti.lifetime = 1.3
	confetti.direction = Vector2(0, -1)
	confetti.spread = 180.0
	confetti.gravity = Vector2(0, 340)
	confetti.initial_velocity_min = 110.0
	confetti.initial_velocity_max = 230.0
	confetti.scale_amount_min = 1.5
	confetti.scale_amount_max = 3.0
	confetti.color = Color(0.3, 0.9, 0.5, 1.0)
	confetti.hue_variation_min = -0.5
	confetti.hue_variation_max = 0.5
	confetti.texture = _dot_texture()
	flag.add_child(confetti)
	ctx.own(confetti)

	ctx.log("flag scene built: goal area + pole/banner polygons + confetti")
	ctx.mark_modified()

func _dot_texture() -> ImageTexture:
	var img: Image = Image.create_empty(3, 3, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(img)
