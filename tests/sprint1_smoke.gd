extends SceneTree
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("PASS: " + message)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame

func _initialize() -> void:
	call_deferred("run_smoke")

func run_smoke() -> void:
	change_scene_to_file("res://scenes/home_menu.tscn")
	await scene_changed
	await frames(3)
	check(current_scene.get_node("VBoxContainer/play").text == "New Game", "Menu loads")
	current_scene.get_node("VBoxContainer/play").pressed.emit()
	await frames(5)
	var world = current_scene
	var player = world.get_node("Player")
	var start: Vector2 = player.position
	Input.action_press("up")
	await frames(24)
	Input.action_release("up")
	check(player.position.y < start.y - 15, "Arrow movement reaches portal from spawn")
	check(player.position.distance_to(world.HOME_PORTAL) < 24, "Portal reachable by walking")
	Input.action_press("interact")
	await frames(2)
	Input.action_release("interact")
	check(world.in_outpost, "E transitions to outpost")
	Input.action_press("up")
	await frames(160)
	Input.action_release("up")
	check(player.position.y > 504 and player.position.y < 520, "Outpost boundary blocks movement")
	# Return to portal using real movement, then exercise reverse transition.
	Input.action_press("down")
	await frames(95)
	Input.action_release("down")
	Input.action_press("interact")
	await frames(2)
	Input.action_release("interact")
	check(not world.in_outpost, "E returns to planet")
	player.position = Vector2(-100, -100)
	await frames(3)
	check(world.HOME_BOUNDS.has_point(player.position), "Outer boundary contains player")
	# Existing key and locked-chest behavior, using actual decoration cells.
	player.position = Vector2(328, 424)
	player.look_at_dir = Vector2.UP
	Input.action_press("up")
	await frames(15)
	Input.action_release("up")
	check(player.position.y >= 420, "Existing decoration collision blocks movement")
	Input.action_press("interact")
	await frames(2)
	Input.action_release("interact")
	check(player.keys == 1, "Existing key pickup works")
	await frames(2)
	player.position = Vector2(440, 424)
	player.look_at_dir = Vector2.UP
	Input.action_press("interact")
	await frames(2)
	Input.action_release("interact")
	check(player.keys == 0 and world.get_node("Decoration").get_cell_source_id(Vector2i(27,25)) == -1, "Key unlocks existing chest")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	Input.parse_input_event(escape)
	await frames(4)
	check(current_scene.scene_file_path.ends_with("home_menu.tscn"), "Escape returns to menu")
	current_scene.get_node("VBoxContainer/play").pressed.emit()
	await frames(5)
	check(current_scene.get_node("Player").keys == 0, "New Game resets keys")
	check(current_scene.get_node("Decoration").get_cell_source_id(Vector2i(20,25)) != -1, "New Game restores collected key")
	current_scene.return_to_menu()
	await frames(4)
	check(current_scene.scene_file_path.ends_with("home_menu.tscn"), "Menu button callback works")
	print("Sprint 1 smoke failures: ", failures)
	quit(1 if failures else 0)
