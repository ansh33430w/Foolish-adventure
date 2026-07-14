extends Control




func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LEVELS/level_1.tscn")
	

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LEVELS/level_2.tscn")

func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LEVELS/level_3.tscn")
