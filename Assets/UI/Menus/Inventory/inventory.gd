extends Control
class_name Inventory
static var s_instance : Inventory = null;

enum Item{
	NotAnItem,
	DoorKey1,
	DoorKey2,
	DoorKey3,
	DoorKey4,
	DoorKey5,
	Digoxin,
	Steroids,
	BoneMarrow,
	Blood,
}

static func itemToText(item : Item):
	match item:
		Item.DoorKey1:
			return "Engineering Bay Door Key"
		Item.DoorKey2:
			return "Engineering Ducts Door Key"
		Item.DoorKey3:
			return "Ship Heart Door Key"
		Item.DoorKey4:
			return "Ship Heart Vents Door Key"
		Item.DoorKey5:
			return "Closet Key"
		Item.Digoxin:
			return "Digoxin"
		Item.Steroids:
			return "Steroids"
		Item.BoneMarrow:
			return "Bone Marrow"
		Item.Blood:
			return "Blood"
		Item.NotAnItem, _:
			return "Error Item"

var currentItems : Array[Item] = [];

@onready var itemInstance = preload("res://Assets/UI/Menus/Inventory/itemInstance.tscn")
@onready var displayList : VBoxContainer = $ScrollContainer/DisplayList;
func obtainItem(obtainedItem : Item) -> void:
	currentItems.push_back(obtainedItem)
	_addItemToDisplay(obtainedItem)
	
func _addItemToDisplay(obtainedItem : Item) -> void:
	var newItemInstance = itemInstance.instantiate()
	#TODO replace with a lookup to get the name?
	#print(newItemInstance, displayList)
	displayList.add_child(newItemInstance)
	newItemInstance.setItemType(obtainedItem)
	
func removeItem(removedItem : Item) -> void:
	currentItems.erase(removedItem)
	_removeItemFromDisplay(removedItem)
	
func _removeItemFromDisplay(removedItem : Item) -> void:
	#BUG currently just removes the first instance of the item, rather than the one you click,
	#    could maybe use an item ID system or something but this works for now.
	var children = displayList.get_children()
	for i in range(0, len(children)):
		var child = displayList.get_child(i)
		if child.getItemType() == removedItem:
			displayList.remove_child(child)
			child.queue_free()
			return;
				
	
func useItem(item : Item):
	#BUG it would have been nice to have this as a superclass that has a use() template,
	#but its easier to redirect all button presses to here for now. If we had lots of items
	#this would need fixing
	
	var outputString : String = "";
	match item:
		#need to replace the prints with message popups
		Item.Digoxin:
			outputString = ("Lowered your heartbeat a bit.. ")
			Player.s_instance.timer._bpm = Player.s_instance.timer._base_bpm - 40;
			removeItem(Item.Digoxin)
		Item.BoneMarrow:
			#increase max health
			Player.s_instance.m_max_health += 1;
			removeItem(Item.BoneMarrow)
		Item.Blood:
			#increase health
			Player.s_instance.m_health = Player.s_instance.m_max_health
			removeItem(Item.Blood)
		Item.Steroids:
			Player.s_instance.damage += 0.5
			removeItem(Item.Steroids)
		Item.DoorKey1:
			outputString = ("Nothing happens, maybe you shouldve interacted with the door instead? You're always like this")
		Item.DoorKey2:
			outputString = ("Nothing happens, you know to press the doors, cmon")
		Item.NotAnItem, _:
			outputString = ("Nothing Happens.")
		
	print(outputString);
	TextPopup.s_instance.set_popup_text(outputString);

func _init() -> void:
	if (s_instance != null):
		queue_free();
		return;
	s_instance = self;
