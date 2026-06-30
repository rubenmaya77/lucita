# En tu script Stats.gd
extends Resource
class_name Stats

@export var max_health: int = 16
@export var health: int = 5

signal health_changed(value)
signal max_health_changed(value)
signal no_health

func take_damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	health_changed.emit(health)
	print("[Stats] health set to:", health)
	if health <= 0:
		print("[Stats] health <= 0, emitting no_health")
		no_health.emit()

func set_max_health(value: int) -> void:
	max_health = value
	if health > max_health:
		health = max_health
	max_health_changed.emit(max_health)
