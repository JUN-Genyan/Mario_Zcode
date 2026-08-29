extends RefCounted

func run(ctx: Variant) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var level: Node = tree.root.get_node("Level1")
	level._back_to_title()
	for i in 30:
		await tree.physics_frame
		if tree.current_scene.name != "Level1":
			break
	ctx.log("transition scene=%s" % tree.current_scene.name)
