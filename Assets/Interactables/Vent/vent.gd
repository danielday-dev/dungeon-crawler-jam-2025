extends InteractableBase

@export var m_openRate : float = 180.0;

func _process(delta: float) -> void:
	if (m_isInteractable): return;
	$Sprite.rotation_degrees.x = clampf($Sprite.rotation_degrees.x - (m_openRate * delta), -89.9, 0.0);
	if ($Sprite.rotation_degrees.x < -89.0):
		reset_tile();
		set_process(false);

func interact_internal() -> void:
	return;
