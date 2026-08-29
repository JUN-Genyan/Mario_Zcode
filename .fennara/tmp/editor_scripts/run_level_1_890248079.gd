@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("level_1.tscn must already exist")
		return
	var level: Node2D = root as Node2D
	if level == null:
		ctx.error("root is not Node2D")
		return
	if level.get_node_or_null("PauseMenu") != null:
		ctx.log("PauseMenu already present, nothing to do")
		return
	var menu: Node = ctx.instance_scene(level, "res://scenes/ui/pause_menu.tscn", "PauseMenu")
	ctx.log("PauseMenu instanced: %s" % String(menu.get_name()))
	ctx.mark_modified()
