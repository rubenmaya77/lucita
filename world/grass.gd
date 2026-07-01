extends Node2D

@export var GRASS_EFFECT: PackedScene

@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	hurtbox.hurt.connect(_on_hurt)

func _on_hurt(_other_hitbox: Hitbox) -> void:
	# 1. Buscamos al jugador usando el grupo "player" que configuramos antes
	var player = get_tree().get_first_node_in_group("player")
	
	# 2. Si el jugador existe y tiene su recurso de estadísticas, le sumamos una vida
	if player and player.stats:
		player.stats.heal(1)
	
	# 3. Creamos el efecto visual de la hierba cortada
	var grass_effect_instance = GRASS_EFFECT.instantiate()
	get_tree().current_scene.add_child(grass_effect_instance)
	grass_effect_instance.global_position = global_position
	
	# 4. Eliminamos la hierba del mapa
	queue_free()
