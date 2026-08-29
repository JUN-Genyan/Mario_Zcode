extends RefCounted

var tree: SceneTree
var level: Node
var gm: Node
var player: CharacterBody2D

func settle(pos: Vector2, frames: int) -> void:
	player.global_position = pos
	player.velocity = Vector2.ZERO
	player.dead = false
	player.show()
	for i in frames:
		await tree.physics_frame

func find_enemy() -> CharacterBody2D:
	for c: Node in level.get_children():
		if c is CharacterBody2D and c.is_in_group("enemy"):
			var e: CharacterBody2D = c
			if not e.stomped and e.global_position.y < 600.0 and e.global_position.x > 300.0:
				return e
	return null

func run(ctx: Variant) -> void:
	tree = Engine.get_main_loop() as SceneTree
	level = tree.root.get_node("Level1")
	gm = tree.root.get_node("GameManager")
	player = level.get_node("Player")
	player.invincible = 999.0
	for i in 10:
		await tree.physics_frame
	await settle(Vector2(45, 440), 30)
	var space: PhysicsDirectSpaceState2D = player.get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(Vector2(45, 400), Vector2(45, 500), 1)
	var hit: Dictionary = space.intersect_ray(query)
	ctx.log("geometry: pos_y=%.1f floor_ray_y=%s" % [player.global_position.y, str(hit.get("position"))])
	Input.action_press("move_right")
	for i in 40:
		await tree.physics_frame
	Input.action_release("move_right")
	for i in 20:
		await tree.physics_frame
	ctx.log("coin_walk: x=%.1f coins=%d score=%d" % [player.global_position.x, gm.coins, gm.score])
	await settle(Vector2(243, 430), 25)
	var qblock: Node = level.get_node("QBlock1")
	Input.action_press("jump")
	for i in 60:
		await tree.physics_frame
	Input.action_release("jump")
	for i in 50:
		await tree.physics_frame
	ctx.log("bump: used=%s coins=%d score=%d" % [str(qblock.used), gm.coins, gm.score])
	await ctx.capture("after_bump")
	var enemy: CharacterBody2D = find_enemy()
	if enemy != null:
		var epos: Vector2 = enemy.global_position
		await settle(Vector2(epos.x, epos.y - 42.0), 10)
		var stomped_ok: bool = false
		for i in 60:
			await tree.physics_frame
			if not is_instance_valid(enemy) or enemy.stomped:
				stomped_ok = true
				break
		ctx.log("stomp: ok=%s" % str(stomped_ok))
		await ctx.capture("after_stomp")
	else:
		ctx.log("stomp: no live enemy found")
	var lives_before: int = gm.lives
	await settle(Vector2(459, 300), 5)
	for i in 200:
		await tree.physics_frame
		if not player.dead and player.global_position.y < 500.0 and i > 60:
			break
	ctx.log("pit_death: lives %d -> %d respawned_x=%.1f" % [lives_before, gm.lives, player.global_position.x])
	await settle(Vector2(1035, 430), 30)
	for i in 60:
		await tree.physics_frame
	var msg: Label = level.get_node("HUD/Overlay/MessageLabel")
	ctx.log("flag: completed=%s msg=%s" % [str(gm.level_completed), msg.text])
	await ctx.capture("after_flag")
