extends CharacterBody2D

@export var attack_range: float = 48.0

func get_player() -> Player:
	return get_tree().get_first_node_in_group("player")

func is_player_close() -> bool:
	var player = get_player()
	return player is Player and global_position.distance_to(player.global_position) <= attack_range

func can_see_player() -> bool:
	# Si quieres solo rango, puedes usar la misma función.
	# Si tienes RayCast, mejor usa línea de visión aquí.
	return is_player_close()
