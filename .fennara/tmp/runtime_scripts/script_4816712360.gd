extends RefCounted

func run(ctx: Variant) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var level: Node = tree.root.get_node("Level1")
	var gm: Node = tree.root.get_node("GameManager")
	var player: CharacterBody2D = level.get_node("Player")
	for i in 20:
		await tree.physics_frame
	var start_y: float = player.global_position.y
	ctx.log("start pos=%s floor=%s lives=%d" % [str(player.global_position), str(player.is_on_floor()), gm.lives])
	Input.action_press("jump")
	var min_y: float = start_y
	for i in 55:
		await tree.physics_frame
		min_y = minf(min_y, player.global_position.y)
		if i == 16:
			await ctx.capture("jump_apex")
	Input.action_release("jump")
	ctx.log("jump height=%.1f px" % (start_y - min_y))
	for i in 30:
		await tree.physics_frame
	var start_x: float = player.global_position.x
	Input.action_press("move_right")
	for i in 45:
		await tree.physics_frame
	Input.action_release("move_right")
	for i in 20:
		await tree.physics_frame
	ctx.log("walk dx=%.1f floor=%s coins=%d score=%d" % [player.global_position.x - start_x, str(player.is_on_floor()), gm.coins, gm.score])
	await ctx.capture("after_walk")
