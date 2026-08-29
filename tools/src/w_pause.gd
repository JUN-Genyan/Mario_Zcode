@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var layer: CanvasLayer = CanvasLayer.new()
		layer.name = "PauseMenu"
		ctx.set_scene_root(layer)
		root = layer
	var menu: CanvasLayer = root as CanvasLayer
	if menu == null:
		ctx.error("root is not CanvasLayer")
		return
	menu.layer = 10
	menu.script = load("res://scenes/ui/pause_menu.gd")

	var panel: Control = Control.new()
	panel.name = "Panel"
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(panel)
	ctx.own(panel)

	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.color = Color(0.05, 0.06, 0.1, 0.6)
	panel.add_child(dim)
	ctx.own(dim)

	var box: VBoxContainer = VBoxContainer.new()
	box.name = "MenuBox"
	box.anchor_left = 0.5
	box.anchor_top = 0.5
	box.anchor_right = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -260.0
	box.offset_right = 260.0
	box.offset_top = -90.0
	box.offset_bottom = 90.0
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	ctx.own(box)

	var paused: Label = _label("PausedLabel", "已暂停", 52, 12)
	paused.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(paused)
	ctx.own(paused)

	var hint: Label = _label("HintLabel", "空格 继续    R 重开本关    Q 退出游戏", 22, 6)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)
	ctx.own(hint)

	var tip: Label = _label("TipLabel", "按 Esc 也可以继续", 15, 4)
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	box.add_child(tip)
	ctx.own(tip)

	ctx.log("pause menu built: dim panel + centered vbox (paused/hint/tip)")
	ctx.mark_modified()

func _label(label_name: String, text_value: String, font_size: int, outline: int) -> Label:
	var label: Label = Label.new()
	label.name = label_name
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 1.0))
	label.add_theme_constant_override("outline_size", outline)
	return label
