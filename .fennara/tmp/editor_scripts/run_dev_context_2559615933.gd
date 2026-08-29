@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		var new_root: Node2D = Node2D.new()
		new_root.name = "DevContext"
		ctx.set_scene_root(new_root)
		ctx.mark_modified()
		ctx.log("Created DevContext scene root")
	else:
		ctx.log("root=%s class=%s" % [String(root.get_name()), root.get_class()])

	ProjectSettings.set_setting("display/window/size/viewport_width", 1280)
	ProjectSettings.set_setting("display/window/size/viewport_height", 720)
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", "keep")
	ProjectSettings.set_setting("rendering/environment/defaults/default_clear_color", Color(0.36, 0.58, 0.99, 1.0))
	ctx.log("window/rendering settings fixed")

	var actions: Dictionary = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_W, KEY_UP],
		"restart": [KEY_R]
	}
	var names: Array = actions.keys()
	for i: int in range(names.size()):
		var action_name: String = names[i]
		var key_list: Array = actions[action_name]
		var events: Array = []
		for j: int in range(key_list.size()):
			var k: int = key_list[j]
			var ev: InputEventKey = InputEventKey.new()
			ev.physical_keycode = k
			events.append(ev)
		ProjectSettings.set_setting("input/" + action_name, {"deadzone": 0.2, "events": events})
		if InputMap.has_action(action_name):
			InputMap.action_erase_events(action_name)
		else:
			InputMap.add_action(action_name, 0.2)
		for e2: InputEvent in events:
			InputMap.action_add_event(action_name, e2)
		ctx.log("action %s -> %d events" % [action_name, events.size()])

	var err: int = ProjectSettings.save()
	ctx.log("ProjectSettings.save() -> %d" % err)
	if err != 0:
		ctx.error("ProjectSettings.save failed with code %d" % err)
