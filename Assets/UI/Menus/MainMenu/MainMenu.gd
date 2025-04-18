extends Control


func _on_play_button_pressed() -> void:
	# Id like to have the heart beat here with a shockwave going outwards before the scene change
	get_tree().change_scene_to_file("res://Levels/level.tscn");


func _on_close_button_pressed() -> void:
	get_tree().quit()
