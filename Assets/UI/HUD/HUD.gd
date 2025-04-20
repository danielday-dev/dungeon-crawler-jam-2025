extends Control


func _on_inv_button_pressed() -> void:
	$Inventory.visible = true

func _on_inventory_mouse_exited() -> void:
	#BUG yeah this doesnt work lmao
	$Inventory.visible = false
