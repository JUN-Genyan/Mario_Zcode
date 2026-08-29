extends RefCounted

func run(ctx: Variant) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	for i in 15:
		await tree.physics_frame
	ctx.log("scene=%s paused=%s" % [tree.current_scene.name, str(tree.paused)])
	await ctx.capture("title_screen")
	Input.action_press("jump")
	await tree.physics_frame
	Input.action_release("jump")
	for i in 40:
		await tree.physics_frame
	ctx.log("after_start scene=%s" % tree.current_scene.name)
