extends InteractableBase

@export var m_item : Inventory.Item = Inventory.Item.NotAnItem;

func interact_internal() -> void:
	Player.s_instance.m_health = Player.s_instance.m_max_health;
	reset_tile();
	visible = false;
