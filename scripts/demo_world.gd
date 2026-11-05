extends Node2D
# Keep both areas alive so keys and opened chests survive the round trip.
const HOME_PORTAL := Vector2(376, 520)
const OUTPOST_PORTAL := Vector2(1128, 600)
const HOME_BOUNDS := Rect2(54, 96, 688, 576)
const OUTPOST_BOUNDS := Rect2(1016, 496, 224, 160)
var in_outpost := false
var status: Label
var portal_hint: Label
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	var outpost := TileMapLayer.new()
	outpost.name = "Outpost"
	outpost.tile_set = $Terrain.tile_set
	outpost.position = Vector2(1000, 480)
	add_child(outpost)
	for x in range(16):
		for y in range(12):
			var edge := x == 0 or x == 15 or y == 0 or y == 11
			outpost.set_cell(Vector2i(x, y), 0, Vector2i(1, 1) if edge else Vector2i(0, 7))
	add_portal(HOME_PORTAL, "Outpost")
	add_portal(OUTPOST_PORTAL, "Return")
	var hud := CanvasLayer.new()
	add_child(hud)
	var panel := VBoxContainer.new()
	panel.position = Vector2(20, 16)
	hud.add_child(panel)
	status = Label.new()
	panel.add_child(status)
	var controls := Label.new()
	controls.text = "Arrow keys: move | E: interact with keys/chests or nearby portal | Esc: menu"
	panel.add_child(controls)
	portal_hint = Label.new()
	panel.add_child(portal_hint)
	var menu := Button.new()
	menu.text = "Return to Menu"
	menu.pressed.connect(return_to_menu)
	panel.add_child(menu)

func add_portal(at: Vector2, title: String) -> void:
	var marker := Polygon2D.new()
	marker.position = at
	marker.polygon = PackedVector2Array([Vector2(-10, 0), Vector2(0, -10), Vector2(10, 0), Vector2(0, 10)])
	marker.color = Color(0.25, 0.95, 1.0)
	add_child(marker)
	var label := Label.new()
	label.position = at + Vector2(-16, 12)
	label.scale = Vector2(0.35, 0.35)
	label.text = title
	add_child(label)

func _physics_process(_delta: float) -> void:
	# Clamp the body inside each area's outer edge; tile collisions still handle walls.
	var bounds := OUTPOST_BOUNDS if in_outpost else HOME_BOUNDS
	player.position = player.position.clamp(bounds.position + Vector2(8, 10), bounds.end - Vector2(8, 10))
	var portal := OUTPOST_PORTAL if in_outpost else HOME_PORTAL
	var near_portal := player.position.distance_to(portal) < 24.0
	status.text = ("Outpost" if in_outpost else "Planet test area") + " | Keys: " + str(player.keys)
	portal_hint.text = "Press E to travel to " + ("the planet" if in_outpost else "the outpost") if near_portal else "Find the cyan diamond portal. Planet portal is north of the starting point."
	if near_portal and Input.is_action_just_pressed("interact"):
		in_outpost = not in_outpost
		player.position = (OUTPOST_PORTAL if in_outpost else HOME_PORTAL) + Vector2(0, -28 if in_outpost else 28)
		player.velocity = Vector2.ZERO
		player.get_node("Camera2D").reset_smoothing()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		return_to_menu()

func return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/home_menu.tscn")
