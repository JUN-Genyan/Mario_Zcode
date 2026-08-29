extends RefCounted

func settle(player: CharacterBody2D, pos: Vector2, tree: SceneTree) -> void:
	player.global_position = pos
	player.velocity = Vector2.ZERO
	player.dead = false
	player.show()
	for i in 30:
		await tree.physics_frame

func run(ctx: Variant) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var level: Node = tree.root.get_node("Level1")
	var gm: Node = tree.root.get_node("GameManager")
	var player: CharacterBody2D = level.get_node("Player")
	var col: CollisionShape2D = player.get_node("CollisionShape2D")
	var rect: RectangleShape2D = col.shape
	ctx.log("shape size=%s col_pos=%s" % [str(rect.size), str(col.position)])
	await settle(player, Vector2(45, 440), tree)
	ctx.log("settled pos=%s floor=%s" % [str(player.global_position), str(player.is_on_floor())])
	var space: PhysicsDirectSpaceState2D = player.get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(Vector2(45, 400), Vector2(45, 500), 1)
	var hit: Dictionary = space.intersect_ray(query)
	ctx.log("floor_ray hit=%s" % str(hit.get("position")))
	await settle(player, Vector2(243, 430), tree)
	var qblock: Node = level.get_node("QBlock1")
	Input.action_press("jump")
	for i in 60:
		await tree.physics_frame
	Input.action_release("jump")
	for i in 50:
		await tree.physics_frame
	ctx.log("bump: qblock1_used=%s coins=%d score=%d pos=%s" % [str(qblock.used), gm.coins, gm.score, str(player.global_position)])
	await ctx.capture("after_bump")
	await settle(player, Vector2(100, 430), tree)
	Input.action_press("move_right")
	for i in 40:
		await tree.physics_frame
	Input.action_release("move_right")
	for i in 30:
		await tree.physics_frame
	ctx.log("coin_walk: pos=%s coins=%d score=%d" % [str(player.global_position), gm.coins, gm.score])
	await ctx.capture("after_coin_walk")
