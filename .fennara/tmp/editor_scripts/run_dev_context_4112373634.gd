@tool
extends RefCounted

func run(ctx) -> void:
	var paths: Array[String] = [
		"res://assets/pixel-platformer/Tilemap/tilemap.png",
		"res://assets/pixel-platformer/Tilemap/tilemap-characters.png",
		"res://assets/pixel-platformer/tile_set.tres",
		"res://assets/generated/coin_sheet.png",
		"res://assets/music/bgm_05.ogg",
		"res://assets/sfx/sfx_00.ogg",
		"res://assets/sfx/sfx_05.ogg"
	]
	var missing: int = 0
	for p: String in paths:
		var ok: bool = ResourceLoader.exists(p)
		var res: Resource = null
		if ok:
			res = load(p)
		var status: String = "OK class=%s" % res.get_class() if res != null else "MISSING"
		if res == null:
			missing += 1
		ctx.log("%s -> %s" % [p, status])
	var ts: TileSet = load("res://assets/pixel-platformer/tile_set.tres") as TileSet
	if ts != null:
		ctx.log("tileset source_count=%d physics_layers=%d" % [ts.get_source_count(), ts.get_physics_layers_count()])
	if missing > 0:
		ctx.error("%d assets not importable yet" % missing)
