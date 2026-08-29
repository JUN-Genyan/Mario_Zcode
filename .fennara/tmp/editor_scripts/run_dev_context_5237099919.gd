@tool
extends RefCounted

func run(ctx) -> void:
	var ts: TileSet = load("res://assets/pixel-platformer/tile_set.tres") as TileSet
	if ts == null:
		ctx.error("tileset missing")
		return
	var src: TileSetAtlasSource = ts.get_source(ts.get_source_id(0)) as TileSetAtlasSource
	if src == null:
		ctx.error("atlas source missing")
		return
	var centered: PackedVector2Array = PackedVector2Array([Vector2(-9, -9), Vector2(9, -9), Vector2(9, 9), Vector2(-9, 9)])
	var fixed: int = 0
	for ty: int in range(9):
		for tx: int in range(20):
			var coords: Vector2i = Vector2i(tx, ty)
			if not src.has_tile(coords):
				continue
			var data: TileData = src.get_tile_data(coords, 0)
			if data == null:
				continue
			if data.get_collision_polygons_count(0) > 0:
				data.set_collision_polygon_points(0, 0, centered)
				fixed += 1
	var err: int = ResourceSaver.save(ts, "res://assets/pixel-platformer/tile_set.tres")
	ctx.log("centered polygons on %d tiles, save -> %d" % [fixed, err])
	if err != 0:
		ctx.error("ResourceSaver.save failed %d" % err)
		return
