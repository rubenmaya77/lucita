extends CharacterBody2D

const HIT_EFFECT = preload("uid://bkexmlihmpv74")
const DEATH_EFFECT = preload("uid://ra0kqr8k26y5")

const SPEED = 30
const FRICTION = 150
const RECOIL_MULTIPLIER = 0.15

@export var min_range: = 4
@export var max_range: = 128
@export var stats: Stats
@export var damage_resistance: int = 1
@export var hit_recoil_multiplier: float = RECOIL_MULTIPLIER

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var center: Marker2D = $Center
@onready var marker_2d: Marker2D = $Marker2D
@onready var navigation_agent_2d: NavigationAgent2D = $Marker2D/NavigationAgent2D

func _ready() -> void:
	add_to_group("rex")
	if stats:
		stats = stats.duplicate()
		stats.no_health.connect(die)
	hurtbox.hurt.connect(take_hit.call_deferred)

func _physics_process(delta: float) -> void:
	var state = playback.get_current_node()
	match state:
		"IdleState":
			pass
		"ChaseState":
			var player = get_player()
			if player is Player:
				navigation_agent_2d.target_position = player.global_position
				var direction = global_position.direction_to(player.global_position)
				velocity = direction * SPEED
				if velocity.x != 0:
					sprite_2d.scale.x = sign(velocity.x)
			else:
				velocity = Vector2.ZERO
			move_and_slide()
		"HitState":
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			move_and_slide()
			if velocity.length() < 5.0:
				playback.travel("ChaseState")

func die() -> void:
	var death_effect = DEATH_EFFECT.instantiate()
	get_tree().current_scene.add_child(death_effect)
	death_effect.global_position = global_position

	var remaining_rex := 0
	for enemy in get_tree().get_nodes_in_group("rex"):
		if is_instance_valid(enemy) and enemy != self:
			remaining_rex += 1

	if remaining_rex == 0:
		get_tree().call_deferred("change_scene_to_file", "res://Play/finish.tscn")

	queue_free()

func take_hit(other_hitbox: Hitbox) -> void:
	var hit_effect = HIT_EFFECT.instantiate()
	get_tree().current_scene.add_child(hit_effect)
	hit_effect.global_position = center.global_position

	if stats:
		var damage_taken = max(1, other_hitbox.damage - damage_resistance)
		stats.take_damage(damage_taken)
		if stats.health <= 0:
			die()
			return

	velocity = other_hitbox.knockback_direction * other_hitbox.knockback_amount * hit_recoil_multiplier
	playback.start("HitState")

func get_player() -> Player:
	return get_tree().get_first_node_in_group("player")

func is_player_in_range() -> bool:
	var result = false
	var player: = get_player()
	if player is Player:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player < max_range and distance_to_player > min_range:
			result = true
	return result

func can_see_player() -> bool:
	if not is_player_in_range():
		return false
	var player: = get_player()
	ray_cast_2d.target_position = to_local(player.global_position)
	ray_cast_2d.force_raycast_update()
	return not ray_cast_2d.is_colliding()
