extends HBoxContainer
class_name ItemInstance

@onready var Inventory = $"../../.."

var _itemType : Inventory.Item

func _ready() -> void:
	_itemType = Inventory.Item.NotAnItem
	refreshItemLabel()
	
func refreshItemLabel():
	$ItemLabel.text = Inventory.itemToText(_itemType)

func setItemType(itemType : Inventory.Item):
	_itemType = itemType
	refreshItemLabel()

func getItemType() -> Inventory.Item:
	return _itemType;


func _on_use_button_pressed() -> void:
	Inventory.useItem(_itemType);
