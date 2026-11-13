extends CharacterBody2D

# _________________SIMPLE FIXES___________________
# 2) Add good load screen background image
# 3) Either dont make going to the menu reset you or put "exit to menu"
# 	 so the player knows his game wont continue where it left out
# 4) Get rid of the pre-existing hole in the wall so you have to break the block 
#    to progress
# 5) Add a delay from when you stop moving to when your charachter starts its 
#	 idle animation
# 6) Make the text box wider to fit the title text and center the text too


const SPEED = 50.0
var keys = 0;
var look_at_dir := Vector2.DOWN
var is_game_over = false;

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var decoration: TileMapLayer = $"../Decoration"
@onready var pickup_success: AudioStreamPlayer2D = $Pickup_Success
@onready var failure: AudioStreamPlayer2D = $failure
@onready var v_box_container: VBoxContainer = $Camera2D/VBoxContainer
@onready var button: Button = $Camera2D/VBoxContainer/Button
@onready var label_2: Label = $Camera2D/VBoxContainer/Label2

func _ready() -> void:
	load_data()

func _physics_process(delta: float) -> void:
	if is_game_over == true:
		return;
	
	process_interaction()
	process_movement()
	move_and_slide()
	
func game_over():
	is_game_over = true
	velocity = Vector2.ZERO
	label_2.text = "Score:" + str(keys * 100)
	v_box_container.show()
	button.grab_focus()

func save_data():
	var save_data = {
		"score": keys * 100,
		"position_x": global_position.x,
		"position_y": global_position.y
		}
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	
func load_data():
	if not FileAccess.file_exists("user://save.json"):
		return
		
	var file = FileAccess.open("user://save.json", FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()

	if save_data == null or not save_data is Dictionary:
		return
		
	keys = int(save_data.get("score", 0) / 100)
	
	global_position = Vector2(
		save_data.get("position_x", 0),
		 save_data.get("position_y", 0)
		)

func process_interaction():
	var pos = get_global_position() + look_at_dir * 16
	var cell = decoration.local_to_map(pos)
	var tile_data = decoration.get_cell_tile_data(cell)
	
	if tile_data == null: return
	var tile_id = tile_data.get_custom_data("chests")
	
	if tile_id ==  3:
		game_over()
		
	
	if Input.is_action_just_pressed("interact"):
		if tile_id == 1:
			keys += 1
			pickup_success.play()
			decoration.erase_cell(cell)
		elif tile_id == 2 and keys > 0:
			keys -= 1
			pickup_success.play()
			decoration.erase_cell(cell)
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
	save_data()
	get_tree().change_scene_to_file("res://scenes/home_menu.tscn")
