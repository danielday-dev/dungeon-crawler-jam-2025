extends Control
class_name Inventory

enum Item{
	DoorKey,
	Digoxin,
}

var currentItems : Array[Item] = [];

@onready var displayList = $ScrollContainer/DisplayList;
func _obtainItem(obtainedItem : Item) -> void:
	currentItems.push_back(obtainedItem)
	_addItemToDisplay(obtainedItem)
	
func _addItemToDisplay(obtainedItem : Item) -> void:
	var newItemLabel = Label.new()
	#TODO replace with a lookup to get the name?
	newItemLabel.text = Item.keys()[obtainedItem]
	displayList.add_child(newItemLabel)
	
func _removeItem(removedItem : Item) -> void:
	currentItems.erase(removedItem)
	_removeItemFromDisplay(removedItem)
	
func _removeItemFromDisplay(removedItem : Item) -> void:
	var itemName = Item.keys()[removedItem]
	var children = displayList.get_children()
	for i in range(0, len(children)):
		var child = get_child(i)
		if child is Label:
			if child.text == itemName:
				child.queue_free()
				
	
func _ready() -> void:
	_obtainItem(Item.DoorKey)
	_obtainItem(Item.DoorKey)
	_obtainItem(Item.DoorKey)
	_obtainItem(Item.DoorKey)
	_removeItem(Item.DoorKey)
	_removeItem(Item.DoorKey)
