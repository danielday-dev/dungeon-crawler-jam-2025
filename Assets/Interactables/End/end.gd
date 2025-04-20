extends InteractableBase

func interact_internal() -> void:
	get_tree().change_scene_to_file("res://Assets/UI/Menus/End/End.tscn")
