@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var screen: Control = Control.new()
		screen.name = "TitleScreen"
		ctx.set_scene_root(screen)
		root = screen
	var ui: Control = root as Control
	if ui == null:
		ctx.error("root is not Control")
		return
	ui.anchor_right = 1.0
	ui.anchor_bottom = 1.0
	ui.script = load("res://scenes/ui/title.gd")

	var bg: ColorRect = ColorRect.new()
	bg.name = "Background"
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.36, 0.58, 0.99, 1.0)
	ui.add_child(bg)
	ctx.own(bg)

	var title: Label = _label("TitleLabel", "MARIO ZCODE", 64, 16)
	title.anchor_left = 0.5
	title.anchor_right = 0.5
	title.offset_left = -420.0
	title.offset_right = 420.0
	title.offset_top = -150.0
	title.offset_bottom = -60.0
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(title)
	ctx.own(title)

	var subtitle: Label = _label("SubtitleLabel", "类 Mario 平台跳跃 · Godot 4.7 + Fennara MCP 构建", 20, 6)
	subtitle.anchor_left = 0.5
	subtitle.anchor_right = 0.5
	subtitle.offset_left = -420.0
	subtitle.offset_right = 420.0
	subtitle.offset_top = -50.0
	subtitle.offset_bottom = -14.0
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(subtitle)
	ctx.own(subtitle)

	var prompt: Label = _label("Prompt", "按 空格键 开始游戏", 30, 8)
	prompt.anchor_left = 0.5
	prompt.anchor_right = 0.5
	prompt.offset_left = -300.0
	prompt.offset_right = 300.0
	prompt.offset_top = 40.0
	prompt.offset_bottom = 90.0
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(prompt)
	ctx.own(prompt)

	var controls: Label = _label("ControlsLabel", "A/D 或 ←/→ 移动    空格/W/↑ 跳跃    S/↓ 下穿平台    R 重开    Esc 暂停", 16, 5)
	controls.anchor_left = 0.5
	controls.anchor_right = 0.5
	controls.anchor_top = 1.0
	controls.anchor_bottom = 1.0
	controls.offset_left = -470.0
	controls.offset_right = 470.0
	controls.offset_top = -70.0
	controls.offset_bottom = -36.0
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(controls)
	ctx.own(controls)

	var quit_hint: Label = _label("QuitHint", "本界面按 Esc 退出游戏", 14, 4)
	quit_hint.anchor_left = 0.5
	quit_hint.anchor_right = 0.5
	quit_hint.anchor_top = 1.0
	quit_hint.anchor_bottom = 1.0
	quit_hint.offset_left = -300.0
	quit_hint.offset_right = 300.0
	quit_hint.offset_top = -32.0
	quit_hint.offset_bottom = -8.0
	quit_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quit_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	ui.add_child(quit_hint)
	ctx.own(quit_hint)

	ctx.log("title screen built: bg + title + subtitle + blinking prompt + controls")
	ctx.mark_modified()

func _label(label_name: String, text_value: String, font_size: int, outline: int) -> Label:
	var label: Label = Label.new()
	label.name = label_name
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 1.0))
	label.add_theme_constant_override("outline_size", outline)
	return label
