@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("DevContext scene missing")
		return
	ctx.log("root=%s" % String(root.get_name()))

	ProjectSettings.set_setting("display/window/size/viewport_width", 960)
	ProjectSettings.set_setting("display/window/size/viewport_height", 540)
	ProjectSettings.set_setting("autoload/GameManager", "*res://autoload/game_manager.gd")

	var events: Array = []
	for k: int in [KEY_S, KEY_DOWN]:
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = k
		events.append(ev)
	ProjectSettings.set_setting("input/down", {"deadzone": 0.2, "events": events})
	if InputMap.has_action("down"):
		InputMap.action_erase_events("down")
	else:
		InputMap.add_action("down", 0.2)
	for e2: InputEvent in events:
		InputMap.action_add_event("down", e2)

	var err: int = ProjectSettings.save()
	ctx.log("ProjectSettings.save() -> %d" % err)
	if err != 0:
		ctx.error("save failed %d" % err)
		return

	var fs: EditorFileSystem = EditorInterface.get_resource_filesystem()
	fs.scan()
	ctx.log("filesystem scan triggered")
