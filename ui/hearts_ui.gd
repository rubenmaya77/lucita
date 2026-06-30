extends Control

@export var player_stats: Stats

@onready var empty_hearts: TextureRect = $EmptyHearts
@onready var full_hearts: TextureRect = $FullHearts

func _ready() -> void:
	# 1. Nos conectamos a ambas señales para escuchar cambios en tiempo real
	player_stats.health_changed.connect(set_full_hearts)
	player_stats.max_health_changed.connect(set_empty_hearts) # <--- ¡AÑADE ESTA LÍNEA!
	
	# 2. Forzamos el dibujo inicial con los valores actuales del recurso (los 5 que pusiste)
	set_empty_hearts(player_stats.max_health)
	set_full_hearts(player_stats.health)

func set_empty_hearts(value: int) -> void:
	empty_hearts.size.x = value * 15

func set_full_hearts(value: int) -> void:
	full_hearts.size.x = value * 15
