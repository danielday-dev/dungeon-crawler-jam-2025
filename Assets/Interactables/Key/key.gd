extends InteractableBase

@export var m_item : Inventory.Item = Inventory.Item.NotAnItem;

func interact_internal() -> void:
	Inventory.s_instance.obtainItem(m_item);
	reset_tile();
	visible = false;
