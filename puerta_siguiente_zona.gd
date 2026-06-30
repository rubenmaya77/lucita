extends Area2D

@export_file("*.tscn") var siguiente_zona: String

# Guardamos si este nivel en específico es libre o no
var es_nivel_libre: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# 1. Detectamos automáticamente si la escena del nivel actual pertenece al grupo "nivel_libre"
	var nivel_actual = get_tree().current_scene
	if nivel_actual and nivel_actual.is_in_group("nivel_libre"):
		es_nivel_libre = true
	
	# 2. Configuración visual inicial basada en el grupo
	if es_nivel_libre:
		modulate.a = 1.0 # Brillo total porque no necesita limpiarse
	elif contar_enemigos_vivos() > 0:
		modulate.a = 0.3 # Opacidad baja si hay enemigos acechando

	# 3. Conectar señales de muerte de los enemigos ya presentes
	var lista_enemigos = get_tree().get_nodes_in_group("enemies")
	for enemigo in lista_enemigos:
		if enemigo and enemigo.has_signal("died"):
			if not enemigo.is_connected("died", Callable(self, "_on_enemy_died")):
				enemigo.connect("died", Callable(self, "_on_enemy_died"))

	# 4. Conectamos al SceneTree para detectar enemigos creados dinámicamente
	if not get_tree().is_connected("node_added", Callable(self, "_on_node_added")):
		get_tree().connect("node_added", Callable(self, "_on_node_added"))

	# Aseguramos el estado inicial de la puerta según los enemigos presentes
	_update_door_state()

# El estado de la puerta ahora se gestiona mediante señales `died` de los enemigos.
# Se eliminó el polling periódico en `_process` para mejorar rendimiento.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Si el nivel es del grupo libre, cambia de escena directo
		if es_nivel_libre:
			if siguiente_zona != "":
				# 🌟 CAMBIO AQUÍ: Usamos call_deferred para cambiar de escena de forma segura
				get_tree().call_deferred("change_scene_to_file", siguiente_zona)
			else:
				print("¡Felicidades! Has completado el juego.")
			return
		
		# Lógica normal para los niveles que SÍ requieren limpieza
		var enemigos_restantes = contar_enemigos_vivos()
		if enemigos_restantes == 0:
			if siguiente_zona != "":
				# 🌟 CAMBIO AQUÍ TAMBIÉN: Cambio de escena seguro
				get_tree().call_deferred("change_scene_to_file", siguiente_zona)
			else:
				print("¡Error! Falta asignar la escena en el Inspector")
		else:
			print("No puedes pasar, aún quedan " + str(enemigos_restantes) + " enemigos vivos.")

# Función segura para contar los enemigos activos en la escena
func contar_enemigos_vivos() -> int:
	var contador = 0
	var lista_enemigos = get_tree().get_nodes_in_group("enemies")
	for enemigo in lista_enemigos:
		if is_instance_valid(enemigo) and not enemigo.is_queued_for_deletion():
			contador += 1
	return contador


func _on_node_added(node: Node) -> void:
	if node and node.is_in_group("enemies") and node.has_signal("died"):
		if not node.is_connected("died", Callable(self, "_on_enemy_died")):
			node.connect("died", Callable(self, "_on_enemy_died"))


func _on_enemy_died() -> void:
	_update_door_state()


func _update_door_state() -> void:
	if es_nivel_libre:
		return
	if contar_enemigos_vivos() == 0:
		modulate.a = 1.0
	else:
		modulate.a = 0.3
