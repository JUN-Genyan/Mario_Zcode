@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("title.tscn missing")
		return
	var names: Array = ["TitleLabel", "SubtitleLabel", "Prompt"]
	for n: String in names:
		var label: Label = root.get_node_or_null(n) as Label
		if label == null:
			ctx.error("missing label %s" % n)
			return
		label.anchor_top = 0.5
		label.anchor_bottom = 0.5
		ctx.log("%s -> anchor_top/bottom=0.5 offsets y=(%s)" % [n, str(Vector2(label.offset_top, label.offset_bottom))])
	ctx.mark_modified()
