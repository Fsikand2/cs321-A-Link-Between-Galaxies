extends CharacterBody2D


const SPEED = 50.0
var keys = 0;
var look_at_dir := Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var decoration: TileMapLayer = $"../Decoration"
@onready var pickup_success: AudioStreamPlayer2D = $Pickup_Success
@onready var failure: AudioStreamPlayer2D = $failure


func _physics_process(delta: float) -> void:
	process_interaction()
	process_movement()
	move_and_slide()

func process_interaction():
	var pos = get_global_position() + look_at_dir * 16
	var cell = decoration.local_to_map(pos)
	var tile_data = decoration.get_cell_tile_data(cell)
	
	if tile_data == null: return
	var tile_id = tile_data.get_custom_data("chests")
	
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
		animated_sprite_2d.play("idle")

func play_animation(dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play("moving")
