@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("DevContext scene missing")
		return
	var actions: Dictionary = {
		"pause": [KEY_ESCAPE, KEY_P],
		"quit_game": [KEY_Q]
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
		ctx.error("save failed %d" % err)
