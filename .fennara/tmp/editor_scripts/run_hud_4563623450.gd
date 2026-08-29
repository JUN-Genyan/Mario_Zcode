@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var layer: CanvasLayer = CanvasLayer.new()
		layer.name = "HUD"
		ctx.set_scene_root(layer)
		root = layer
	var hud: CanvasLayer = root as CanvasLayer
	if hud == null:
		ctx.error("root is not CanvasLayer")
		return

	var overlay: Control = Control.new()
	overlay.name = "Overlay"
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(overlay)
	ctx.own(overlay)

	var score: Label = _label("ScoreLabel", "SCORE 000000", Vector2(8, 4), 20)
	overlay.add_child(score)
	ctx.own(score)
	var coins: Label = _label("CoinLabel", "COINS 00", Vector2(170, 4), 20)
	overlay.add_child(coins)
	ctx.own(coins)
	var lives: Label = _label("LivesLabel", "LIVES 3", Vector2(330, 4), 20)
	overlay.add_child(lives)
	ctx.own(lives)

	var message: Label = _label("MessageLabel", "", Vector2.ZERO, 34)
	message.anchor_left = 0.5
	message.anchor_top = 0.5
	message.anchor_right = 0.5
	message.anchor_bottom = 0.5
	message.offset_left = -250.0
	message.offset_top = -30.0
	message.offset_right = 250.0
	message.offset_bottom = 30.0
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.visible = false
	message.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 1.0))
	message.add_theme_constant_override("outline_size", 10)
	overlay.add_child(message)
	ctx.own(message)

	ctx.log("hud scene built: overlay + stat labels + centered message")
	ctx.mark_modified()

func _label(label_name: String, text_value: String, pos: Vector2, font_size: int) -> Label:
	var label: Label = Label.new()
	label.name = label_name
	label.text = text_value
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 1.0))
	label.add_theme_constant_override("outline_size", 6)
	return label
