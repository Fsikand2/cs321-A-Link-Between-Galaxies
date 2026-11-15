
extends CharacterBody2D

signal died

@export var speed: float = 25.0
@export var Jump_velocity: float = -300.0
@export var max_health: int = 3
@export var attack_cooldown: float = 2.0
@export var attack_damage: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectArea
@onready var attack_area: Area2D = $AttackArea
@onready var collision: CollisionShape2D = $CollisionShape2D

var health: int
var player: Node2D = null
var cooldown: float = 0.0

var is_dead: bool = false
var is_hurt: bool = false
var is_attacking: bool = false


func _ready() -> void:
	health = max_health
	sprite.play("Idle")

	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_left)
	attack_area.body_entered.connect(_on_attack_hit)
	sprite.animation_finished.connect(_on_animation_finished)
	

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if cooldown > 0:
		cooldown -= delta
		
	if is_hurt:
		velocity = Vector2.ZERO

	elif player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		if cooldown <= 0:
			attack()
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func attack() -> void:
	cooldown = attack_cooldown
	sprite.play("Jump")


func take_damage(amount: int = 1) -> void:
	if is_dead or is_hurt:
		return

	health -= amount

	if health <= 0:
		die()
	else:
		hurt()


func hurt() -> void:
	is_hurt = true
	is_attacking = false
	velocity.x = 0
	sprite.play("Hurt")


func die() -> void:
	is_dead = true
	is_attacking = false
	velocity = Vector2.ZERO

	# Disable enemy collision and attacks
	collision.set_deferred("disabled", true)
	attack_area.set_deferred("monitoring", false)
	detection_area.set_deferred("monitoring", false)

	sprite.play("Death")


func on_death() -> void:
	# Custom death event
	died.emit()

	# Remove slime
	queue_free()


func _on_animation_finished() -> void:
	if sprite.animation == "Death":
		on_death()
	elif sprite.animation == "Hurt":
		is_hurt = false
		sprite.play("Idle")


func _on_player_detected(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


func _on_player_left(body: Node2D) -> void:
	if body == player:
		player = null


func _on_attack_hit(body: Node2D) -> void:
	if is_dead or not is_attacking:
		return

	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
