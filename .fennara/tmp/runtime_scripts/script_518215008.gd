extends RefCounted

func run(ctx: Variant) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var level: Node = tree.root.get_node("Level1")
	var label: Label = level.get_node("HUD/Overlay/MessageLabel")
	ctx.log("visible=%s pos=%s size=%s font=%d align=%d text='%s'" % [str(label.visible), str(label.position), str(label.size), label.get_theme_font_size("font_size"), label.horizontal_alignment, label.text])
	label.text = "TEST MESSAGE"
	label.show()
	for i in 8:
		await tree.physics_frame
	ctx.log("after show: visible=%s" % str(label.visible))
	await ctx.capture("msg_test")
