extends CanvasLayer




func _on_roll_pressed() -> void:
	$roll.modulate= Color(1, 0.5, 0.5)



func _on_roll_released() -> void:
	$roll.modulate= Color(1, 1, 1)




func _on_left_pressed() -> void:
	$left.modulate= Color(1, 0.5, 0.5)
	
	
	


func _on_left_released() -> void:
	$left.modulate= Color(1, 1, 1)
	
	
	


func _on_right_pressed() -> void:
	$right.modulate= Color(1, 0.5, 0.5)
	
	
	
	


func _on_right_released() -> void:
	$right.modulate= Color(1, 1, 1)


func _on_up_pressed() -> void:
	$up.modulate= Color(1, 0.5, 0.5)


func _on_up_released() -> void:
	$up.modulate= Color(1, 1, 1)


func _on_attack_pressed() -> void:
	$attack.modulate= Color(1, 0.5, 0.5)


func _on_attack_released() -> void:
	$attack.modulate= Color(1, 1, 1)


func _on_down_pressed() -> void:
	$down.modulate= Color(1, 0.5, 0.5)


func _on_down_released() -> void:
	$down.modulate= Color(1, 1, 1)
