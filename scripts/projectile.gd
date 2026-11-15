
extends Area2D

@export var speed: float = 45.0
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation = direction.angle() + PI / 2
	animated_sprite_2d.play("default")
	audio_stream_player_2d.play()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()
