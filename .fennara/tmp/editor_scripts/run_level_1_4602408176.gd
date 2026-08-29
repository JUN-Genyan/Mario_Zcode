@tool
extends RefCounted

const TILE := 18
const SRC_ID := 0

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var new_root: Node2D = Node2D.new()
		new_root.name = "Level1"
		ctx.set_scene_root(new_root)
		root = new_root
	var level: Node2D = root as Node2D
	if level == null:
		ctx.error("root is not Node2D")
		return
	level.script = load("res://scenes/levels/level_1.gd")

	var rows: Array[String] = _level_rows()
	for i: int in range(rows.size()):
		if rows[i].length() != 60:
			ctx.error("row %d length %d != 60" % [i, rows[i].length()])
			return

	var ground: TileMapLayer = TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = load("res://assets/pixel-platformer/tile_set.tres")
	level.add_child(ground)
	ctx.own(ground)

	var par: ParallaxBackground = ParallaxBackground.new()
	par.name = "Parallax"
	level.add_child(par)
	ctx.own(par)
	var clouds: ParallaxLayer = ParallaxLayer.new()
	clouds.name = "CloudLayer"
	clouds.motion_scale = Vector2(0.25, 1.0)
	clouds.motion_mirroring = Vector2(960, 0)
	par.add_child(clouds)
	ctx.own(clouds)
	var cloud_spots: Array = [[140.0, 110.0, 1.2], [420.0, 70.0, 1.0], [700.0, 130.0, 1.4], [880.0, 90.0, 1.0]]
	for c: Array in cloud_spots:
		var cloud: Polygon2D = _cloud()
		cloud.position = Vector2(c[0], c[1])
		cloud.scale = Vector2(c[2], c[2])
		clouds.add_child(cloud)
		ctx.own(cloud)
	var hills: ParallaxLayer = ParallaxLayer.new()
	hills.name = "HillLayer"
	hills.motion_scale = Vector2(0.55, 1.0)
	hills.motion_mirroring = Vector2(960, 0)
	par.add_child(hills)
	ctx.own(hills)
	var hill_spots: Array = [[150.0, 260.0, 90.0], [480.0, 200.0, 60.0], [820.0, 300.0, 110.0]]
	for h: Array in hill_spots:
		var hill: Polygon2D = _hill(h[1], h[2])
		hill.position = Vector2(h[0], 468.0)
		hills.add_child(hill)
		ctx.own(hill)

	var counts: Dictionary = {}
	var spawn_at: Vector2 = Vector2(45, 459)
	for y: int in range(rows.size()):
		var line: String = rows[y]
		for x: int in range(line.length()):
			var ch: String = line[x]
			if ch == ".":
				continue
			var center: Vector2 = Vector2(x * TILE + 9.0, y * TILE + 9.0)
			match ch:
				"G":
					ground.set_cell(Vector2i(x, y), SRC_ID, Vector2i((x * 7 + y * 3) % 4, 0))
				"D":
					ground.set_cell(Vector2i(x, y), SRC_ID, Vector2i(17 + ((x * 5 + y * 11) % 3), 1))
				"C":
					_place(counts, ctx, level, "res://scenes/items/coin.tscn", "Coin", center)
				"g":
					_place(counts, ctx, level, "res://scenes/enemies/enemy.tscn", "Enemy", center)
				"Q":
					_place(counts, ctx, level, "res://scenes/items/block.tscn", "QBlock", center)
				"P":
					_place(counts, ctx, level, "res://scenes/objects/platform.tscn", "Platform", center)
				"X":
					var crate: Node2D = _place(counts, ctx, level, "res://scenes/items/block.tscn", "Crate", center)
					crate.set("content", "none")
				"F":
					var flag: Node2D = ctx.instance_scene(level, "res://scenes/objects/flag.tscn", "Flag")
					flag.position = Vector2(center.x, (y + 1) * TILE)
				"S":
					spawn_at = center

	var player: Node2D = ctx.instance_scene(level, "res://scenes/player/player.tscn", "Player")
	player.position = spawn_at
	ctx.instance_scene(level, "res://scenes/ui/hud.tscn", "HUD")

	ctx.log("placed: %s spawn=%s" % [str(counts), str(spawn_at)])
	ctx.mark_modified()

func _place(counts: Dictionary, ctx: Variant, parent: Node, scene_path: String, base: String, pos: Vector2) -> Node2D:
	counts[base] = int(counts.get(base, 0)) + 1
	var node: Node2D = ctx.instance_scene(parent, scene_path, "%s%d" % [base, counts[base]])
	node.position = pos
	return node

func _cloud() -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = Color(1, 1, 1, 0.92)
	poly.polygon = PackedVector2Array([
		Vector2(-30, 10), Vector2(-30, 0), Vector2(-20, -8), Vector2(-10, -6), Vector2(-4, -14),
		Vector2(8, -14), Vector2(14, -6), Vector2(26, -4), Vector2(30, 2), Vector2(30, 10)
	])
	return poly

func _hill(width: float, height: float) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.color = Color(0.2, 0.68, 0.32, 1.0)
	var pts: PackedVector2Array = PackedVector2Array()
	var n: int = 18
	for i: int in range(n + 1):
		var a: float = PI * float(i) / float(n)
		pts.append(Vector2(-width * 0.5 * cos(a), -height * sin(a)))
	poly.polygon = pts
	return poly

func _level_rows() -> Array[String]:
	var rows: Array[String] = []
	for i: int in range(14):
		rows.append(".".repeat(60))
	rows.append(".".repeat(36) + "CCC" + ".".repeat(21))
	rows.append(".".repeat(36) + "PPP" + ".".repeat(21))
	rows.append(".".repeat(60))
	rows.append(".".repeat(31) + "CCC" + ".".repeat(26))
	rows.append(".".repeat(31) + "QBQ" + ".".repeat(26))
	rows.append(".".repeat(27) + "CCC" + ".".repeat(30))
	rows.append(".".repeat(27) + "PPP" + ".".repeat(30))
	rows.append(".".repeat(60))
	rows.append(".".repeat(13) + "XQXQX" + ".".repeat(3) + "CCC" + ".".repeat(21) + "CCC" + ".".repeat(8) + "X" + ".".repeat(3))
	rows.append(".".repeat(21) + "PPP" + ".".repeat(21) + "PPP" + ".".repeat(7) + "XX" + ".".repeat(3))
	rows.append("......C.C.C" + ".".repeat(13) + "CCC" + ".".repeat(27) + "XXX" + ".".repeat(3))
	rows.append("..S" + ".".repeat(7) + "g" + ".".repeat(9) + "g" + ".".repeat(12) + "g" + ".".repeat(6) + "g" + ".".repeat(10) + "g" + "." + "XXXX" + "." + "F" + ".")
	var ground_row: String = "G".repeat(24) + "..." + "G".repeat(18) + "..." + "G".repeat(12)
	var dirt_row: String = "D".repeat(24) + "..." + "D".repeat(18) + "..." + "D".repeat(12)
	rows.append(ground_row)
	rows.append(dirt_row)
	rows.append(dirt_row)
	rows.append(dirt_row)
	return rows
