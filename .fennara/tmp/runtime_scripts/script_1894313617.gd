extends RefCounted

func tap(action: String) -> void:
	Input.action_press(action)
	await Engine.get_main_loop().physics_frame
	Input.action_release(action)

func run(ctx: Variant) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	for i in 12:
		await tree.physics_frame
	await ctx.capture("title_fixed")
	await tap("jump")
	for i in 40:
		await tree.physics_frame
	ctx.log("scene=%s" % tree.current_scene.name)
	var level: Node = tree.current_scene
	var player: CharacterBody2D = level.get_node("Player")
	player.invincible = 999.0
	var panel: Control = level.get_node("PauseMenu/Panel")
	await tap("pause")
	for i in 5:
		await tree.physics_frame
	ctx.log("paused=%s panel=%s" % [str(tree.paused), str(panel.visible)])
	await ctx.capture("pause_menu")
	await tap("jump")
	for i in 5:
		await tree.physics_frame
	ctx.log("resumed paused=%s panel=%s" % [str(tree.paused), str(panel.visible)])
	await tap("pause")
	for i in 5:
		await tree.physics_frame
	ctx.log("re-paused=%s" % str(tree.paused))
	await tap("quit_game")
	for i in 5:
		await tree.physics_frame
	ctx.log("still_running_after_quit=%s" % str(tree.paused))
