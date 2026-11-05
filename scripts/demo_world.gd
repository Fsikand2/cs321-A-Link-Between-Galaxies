extends Node2D
# Both areas stay loaded so keys and opened chests survive the round trip.
const HOME_PORTAL := Vector2(376, 520)
const OUTPOST_PORTAL := Vector2(1128, 600)
const HOME_BOUNDS := Rect2(54, 96, 688, 576)
const OUTPOST_BOUNDS := Rect2(1016, 496, 224, 160)
const TILE_TEXTURE := preload("res://assets/images/CosmicLilac_Tiles.png")
var in_outpost := false
var status: Label
var portal_hint: Label
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	build_outpost()
	add_landing_pad(HOME_PORTAL, "OUTPOST TRANSFER")
	add_landing_pad(OUTPOST_PORTAL, "PLANET TRANSFER")
	build_hud()
	portal_hint = Label.new()
	portal_hint.name = "EntrancePrompt"
	portal_hint.scale = Vector2.ONE / 3.0
	portal_hint.add_theme_color_override("font_color", Color("fff1ce"))
	portal_hint.add_theme_color_override("font_shadow_color", Color("171b3b"))
	portal_hint.add_theme_constant_override("shadow_offset_x", 2)
	portal_hint.add_theme_constant_override("shadow_offset_y", 2)
	portal_hint.z_index = 10
	add_child(portal_hint)

func build_outpost() -> void:
	var outpost := TileMapLayer.new()
	outpost.name = "Outpost"
	outpost.tile_set = $Terrain.tile_set
	outpost.position = Vector2(1000, 480)
	add_child(outpost)
	move_child(outpost, 0) # Floor must draw behind the astronaut.
	for x in range(16):
		for y in range(12):
			var edge := x == 0 or x == 15 or y == 0 or y == 11
			outpost.set_cell(Vector2i(x, y), 0, Vector2i(1, 1) if edge else Vector2i(6, 2))
	# Storage lockers and supplies frame the room, leaving the central route clear.
	for cell in [Vector2i(2, 2), Vector2i(3, 2), Vector2i(12, 2), Vector2i(13, 2)]:
		outpost.set_cell(cell, 0, Vector2i(12, 1))
	for cell in [Vector2i(2, 7), Vector2i(13, 7)]:
		outpost.set_cell(cell, 0, Vector2i(10, 2))
	add_world_label(Vector2(1128, 520), "OUTPOST 01", Color("fff1ce"))
	add_world_label(Vector2(1048, 544), "SUPPLIES", Color("e2b2ed"))
	add_world_label(Vector2(1208, 544), "STORAGE", Color("e2b2ed"))

func add_landing_pad(at: Vector2, title: String) -> void:
	var pad := Sprite2D.new()
	pad.texture = TILE_TEXTURE
	pad.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pad.region_enabled = true
	# The existing 48px platform artwork includes its own metal border.
	pad.region_rect = Rect2(8, 8, 48, 48)
	pad.position = at
	add_child(pad)
	move_child(pad, player.get_index()) # Pads draw over floors, under the player.
	add_world_label(at + Vector2(0, 27), title, Color("e2b2ed"))

func add_world_label(at: Vector2, title: String, color: Color) -> void:
	var label := Label.new()
	label.text = title
	label.scale = Vector2.ONE / 3.0
	label.add_theme_color_override("font_color", color)
	label.position = at - Vector2(label.get_minimum_size().x / 6.0, 0)
	add_child(label)

func hud_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.08, 0.18, 0.94)
	style.border_color = Color("80549c")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 16)
	panel.add_theme_stylebox_override("panel", hud_style())
	root.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	panel.add_child(row)
	status = Label.new()
	status.add_theme_color_override("font_color", Color("fff1ce"))
	row.add_child(status)
	var menu := Button.new()
	menu.text = "Menu · Esc"
	menu.focus_mode = Control.FOCUS_NONE
	menu.pressed.connect(return_to_menu)
	row.add_child(menu)
	var controls := PanelContainer.new()
	root.add_child(controls)
	controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	controls.offset_left = 16
	controls.offset_top = -52
	controls.offset_bottom = -16
	controls.add_theme_stylebox_override("panel", hud_style())
	var hint := Label.new()
	hint.text = "Arrows  Move     E  Interact"
	hint.add_theme_font_size_override("font_size", 14)
	controls.add_child(hint)

func _physics_process(_delta: float) -> void:
	# Outer guards supplement the authored tile collisions.
	var bounds := OUTPOST_BOUNDS if in_outpost else HOME_BOUNDS
	player.position = player.position.clamp(bounds.position + Vector2(8, 10), bounds.end - Vector2(8, 10))
	var portal := OUTPOST_PORTAL if in_outpost else HOME_PORTAL
	var near_portal := player.position.distance_to(portal) < 24.0
	status.text = ("Outpost 01" if in_outpost else "Planet surface") + "   |   Keys: " + str(player.keys)
	portal_hint.visible = near_portal
	portal_hint.text = "Press E to return to planet" if in_outpost else "Press E to enter outpost"
	portal_hint.position = portal + Vector2(-portal_hint.get_minimum_size().x / 6.0, -38)
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
