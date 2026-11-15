extends CharacterBody2D

const SPEED = 50.0
var keys = 0;
var look_at_dir := Vector2.DOWN
var is_game_over = false
var removed_cells: Array = []

@export var projectile_scene: PackedScene
@export var shoot_cooldown: float = 0.3

var shoot_timer: float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var decoration: TileMapLayer = $"../Decoration"
@onready var pickup_success: AudioStreamPlayer2D = $Pickup_Success
@onready var failure: AudioStreamPlayer2D = $failure
@onready var v_box_container: VBoxContainer = $Camera2D/VBoxContainer
@onready var button: Button = $Camera2D/VBoxContainer/Button
@onready var label_2: Label = $Camera2D/VBoxContainer/Label2

func _ready() -> void:
	if not SaveGame.data_to_load.is_empty():
		load_data(SaveGame.data_to_load)
	SaveGame.data_to_load = {}

func _physics_process(delta: float) -> void:
	if is_game_over == true:
		return;
	
	process_interaction()
	
	if shoot_timer > 0:
		shoot_timer -= delta

	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot()
		shoot_timer = shoot_cooldown
		
	process_movement()
		
	move_and_slide()
	
func shoot():
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()

	get_parent().add_child(projectile)

	projectile.global_position = global_position + look_at_dir * 16
	projectile.direction = look_at_dir.normalized()
	
func game_over():
	is_game_over = true
	velocity = Vector2.ZERO
	label_2.text = "Score:" + str(keys * 100)
	v_box_container.show()
	button.grab_focus()

func save_data() -> bool:
	var data = {
		"keys": keys,
		"position_x": global_position.x,
		"position_y": global_position.y,
		"removed_cells": removed_cells,
		"game_over": is_game_over
	}
	var file = FileAccess.open(SaveGame.SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(data))
	file.flush()
	var write_error = file.get_error()
	file.close()
	if write_error != OK:
		return false

	var result = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(SaveGame.SAVE_PATH + ".tmp"),
		ProjectSettings.globalize_path(SaveGame.SAVE_PATH)
	)
	return result == OK

func load_data(data: Dictionary) -> void:
	keys = int(data["keys"])
	global_position = Vector2(data["position_x"], data["position_y"])
	removed_cells = data["removed_cells"]
	for cell in removed_cells:
		decoration.erase_cell(Vector2i(int(cell[0]), int(cell[1])))
	if data["game_over"]:
		game_over()

func process_interaction():
	# Pressure plates: press the button you're standing on
	var under_cell = decoration.local_to_map(decoration.to_local(global_position))
	var under_data = decoration.get_cell_tile_data(under_cell)
	if under_data and under_data.get_custom_data("chests") == 4:
		press_button(under_cell)

	var pos = get_global_position() + look_at_dir * 16
	var cell = decoration.local_to_map(decoration.to_local(pos))
	var tile_data = decoration.get_cell_tile_data(cell)
	
	if tile_data == null: return
	var tile_id = tile_data.get_custom_data("chests")
	
	if tile_id == 3:
		game_over()
		return
		
	
	if Input.is_action_just_pressed("interact"):
		if tile_id == 1:
			keys += 1
			pickup_success.play()
			decoration.erase_cell(cell)
			removed_cells.append([cell.x, cell.y])
		elif tile_id == 4 and keys > 0:
			keys -= 1
			pickup_success.play()
			decoration.erase_cell(cell)
			removed_cells.append([cell.x, cell.y])
		elif tile_id == 4:  # button (facing it + E also works)
			press_button(cell)
		else:
			failure.play();

func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	process_animation(direction)
	
func process_animation(dir: Vector2) -> void:
	if velocity != Vector2.ZERO:
		look_at_dir = velocity.normalized()
		play_animation(dir)
	else:
		# Wait a little bit THEN start idle animation
		animated_sprite_2d.play("idle")

func play_animation(dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play("moving")


func _on_button_pressed() -> void:
	get_parent().return_to_menu()

func count_tiles(id: int) -> int:
	var count := 0
	for c in decoration.get_used_cells():
		var data := decoration.get_cell_tile_data(c)
		if data and data.get_custom_data("chests") == id:
			count += 1
	return count

func open_button_doors() -> void:
	var opened := 0
	for door_cell in decoration.get_used_cells():
		var data := decoration.get_cell_tile_data(door_cell)
		if data and data.get_custom_data("chests") == 5:
			decoration.erase_cell(door_cell)
			removed_cells.append([door_cell.x, door_cell.y])
			opened += 1

func press_button(cell: Vector2i) -> void:
	pickup_success.play()
	decoration.erase_cell(cell)
	removed_cells.append([cell.x, cell.y])
	if count_tiles(4) == 0:  # all buttons pressed
		open_button_doors()