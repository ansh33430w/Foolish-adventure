extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var cur_scene = get_tree().current_scene.scene_file_path
		var nxtlevel = cur_scene.to_int() + 1 
		var nxtscene = "res://scenes/levels/level_" + str(nxtlevel) + ".tscn"
		get_tree().change_scene_to_file(nxtscene)
