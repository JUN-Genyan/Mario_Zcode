extends RefCounted

func run(ctx: Variant) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	for i in 10:
		await tree.physics_frame
	var level: Node = tree.root.get_node("Level1")
	var player: CharacterBody2D = level.get_node("Player")
	player.invincible = 999.0
	player.global_position = Vector2(1053, 430)
	player.velocity = Vector2.ZERO
	player.dead = false
	player.show()
	for i in 40:
		await tree.physics_frame
	ctx.log("flag reached, scene=%s msg=%s" % [tree.current_scene.name, level.get_node("HUD/Overlay/MessageLabel").text])
	for i in 200:
		await tree.physics_frame
		if tree.current_scene.name != "Level1":
			break
	ctx.log("after_win scene=%s" % tree.current_scene.name)
	await ctx.capture("back_to_title")
