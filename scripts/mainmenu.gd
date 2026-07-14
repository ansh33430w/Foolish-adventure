extends Control




func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LEVELS/level_1.tscn")




func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")
