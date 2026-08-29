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
	var qblock: Node = level.get_node("QBlock1")
	ctx.log("setup: qblock1_pos=%s" % str(qblock.global_position))
	await settle(Vector2(261, 430), 25)
	Input.action_press("jump")
	for i in 60:
		await tree.physics_frame
	Input.action_release("jump")
	for i in 50:
		await tree.physics_frame
	ctx.log("bump: used=%s coins=%d score=%d lives=%d" % [str(qblock.used), gm.coins, gm.score, gm.lives])
	await ctx.capture("after_bump")
	var enemy: CharacterBody2D = find_enemy()
	if enemy != null:
		var score_before: int = gm.score
		await settle(Vector2(enemy.global_position.x, enemy.global_position.y - 46.0), 5)
		var stomped_ok: bool = false
		for i in 60:
			if is_instance_valid(enemy) and not enemy.stomped:
				player.global_position.x = enemy.global_position.x
				player.velocity.x = 0.0
			await tree.physics_frame
			if not is_instance_valid(enemy) or enemy.stomped:
				stomped_ok = true
				break
		Input.action_release("move_right")
		Input.action_release("move_left")
		for i in 20:
			await tree.physics_frame
		ctx.log("stomp: ok=%s score +%d" % [str(stomped_ok), gm.score - score_before])
		await ctx.capture("after_stomp")
	else:
		ctx.log("stomp: no live enemy found")
	await settle(Vector2(1053, 430), 30)
	for i in 60:
		await tree.physics_frame
	var msg: Label = level.get_node("HUD/Overlay/MessageLabel")
	ctx.log("flag: completed=%s msg=%s" % [str(gm.level_completed), msg.text])
	await ctx.capture("after_flag")
