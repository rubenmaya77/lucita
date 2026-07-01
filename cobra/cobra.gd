extends CharacterBody2D

signal died

const SPEED = 30
const FRICTION = 150

@export var min_range: = 4
@export var max_range: = 128
@export var attack_range: float = 48.0
@export var stats: Stats

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var chase_sprite: AnimatedSprite2D = $chase
@onready var attack_sprite: AnimatedSprite2D = $attack
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var _previous_state: String = ""

func _ready() -> void:
	add_to_group("enemies")
	if stats:
		stats = stats.duplicate()
		stats.no_health.connect(die)
	hurtbox.hurt.connect(take_hit.call_deferred)
	# Estado inicial de sprites: solo se muestra el de persecución
	chase_sprite.visible = true
	attack_sprite.visible = false
	chase_sprite.play()

func _physics_process(delta: float) -> void:
	var state = playback.get_current_node()
	if state != _previous_state:
		_update_sprites(state)
		_previous_state = state
	match state:
		"attack":
			velocity = Vector2.ZERO
			move_and_slide()
			
		"chase":
			var player = get_player()
			if player is Player:
				velocity = global_position.direction_to(player.global_position) * SPEED
				
				# Orienta el sprite según la dirección
				if velocity.x != 0:
					chase_sprite.scale.x = sign(velocity.x)
					attack_sprite.scale.x = sign(velocity.x)
			else:
				velocity = Vector2.ZERO
			move_and_slide()
			
		"hit":
			# Aplica fricción para que el retroceso se detenga poco a poco
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			move_and_slide()
			
			# Cuando el enemigo se detiene, vuelve a perseguir
			if velocity.length() < 5.0:
				playback.travel("chase")

func _update_sprites(state: String) -> void:
	match state:
		"chase":
			chase_sprite.visible = true
			attack_sprite.visible = false
			chase_sprite.play()
			attack_sprite.stop()

		"attack":
			chase_sprite.visible = false
			attack_sprite.visible = true
			attack_sprite.play()
			chase_sprite.stop()

		"hit":
			# Durante el golpe ocultamos la animación de ataque/persecución
			chase_sprite.visible = false
			attack_sprite.visible = false
			chase_sprite.stop()
			attack_sprite.stop()

func die() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player is Player and player.stats:
		player.stats.max_health += 10
		player.stats.health += 10
	
	emit_signal("died")
	queue_free()

func take_hit(other_hitbox: Hitbox) -> void:
	if stats:
		stats.take_damage(other_hitbox.damage)
		if stats.health <= 0:
			die()
			return
	
	# Aplicamos la fuerza de empuje
	velocity = other_hitbox.knockback_direction * other_hitbox.knockback_amount
	
	# Cambia al estado de golpe
	playback.start("hit")

func get_player() -> Player:
	return get_tree().get_first_node_in_group("player")

func is_player_close() -> bool:
	var player = get_player()
	return player is Player and global_position.distance_to(player.global_position) <= attack_range

func can_see_player() -> bool:
	# Por ahora solo usa rango; si añades RayCast2D puedes mejorar esto
	return is_player_close()
