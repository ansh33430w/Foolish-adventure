extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var curpath =  get_tree().current_scene.scene_file_path
		var regex   = RegEx.new(
			
		)
		regex.compile("level_(\\d+)")
		var result = regex.search(curpath
		)
		if result:
			var nxtlevel = int(result.get_string(1))
			var nextpath = curpath.replace(
				"level_d%" % nxtlevel ,
				"level_d% " % (nxtlevel+1)
			)
