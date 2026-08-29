extends RefCounted

func run(ctx: Variant) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var player: CharacterBody2D = tree.root.get_node("Level1/Player")
	player.invincible = 999.0
	Input.action_press("restart")
	await tree.physics_frame
	Input.action_release("restart")
	for i in 20:
		await tree.physics_frame
	var level: Node = tree.root.get_node("Level1")
	var gm: Node = tree.root.get_node("GameManager")
	player = level.get_node("Player")
	player.invincible = 999.0
	player.global_position = Vector2(1053, 430)
	player.velocity = Vector2.ZERO
	player.dead = false
	player.show()
	for i in 55:
		await tree.physics_frame
	var msg: Label = level.get_node("HUD/Overlay/MessageLabel")
	ctx.log("completed=%s text='%s' visible=%s score=%d" % [str(gm.level_completed), msg.text, str(msg.visible), gm.score])
	await ctx.capture("flag_msg_check")
