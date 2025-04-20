extends InteractableBase

@export var m_openRate : float = 1.6;
@export var m_openHeight : float = 1.0;
@export var m_item : Inventory.Item = Inventory.Item.NotAnItem;

func _process(delta: float) -> void:
	if (m_isInteractable): return;
	$Sprite.position.y = clampf($Sprite.position.y + (m_openRate * delta), 0.0, m_openHeight);
	if ($Sprite.position.y >= m_openHeight):
		reset_tile();
		set_process(false);
		
func interact_internal() -> void:
	if (!Inventory.s_instance.currentItems.has(m_item)): return;
