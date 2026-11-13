extends Node2D

# Keep the astronaut inside the map; tile collisions handle individual walls.
const PLAYABLE_BOUNDS := Rect2(54, 96, 688, 576)
const PLAYER_MARGIN := Vector2(8, 10)
var status: Label
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	build_hud()

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
	player.position = player.position.clamp(
		PLAYABLE_BOUNDS.position + PLAYER_MARGIN,
		PLAYABLE_BOUNDS.end - PLAYER_MARGIN
	)
	status.text = "Keys: " + str(player.keys)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		return_to_menu()
		

func return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/home_menu.tscn")
