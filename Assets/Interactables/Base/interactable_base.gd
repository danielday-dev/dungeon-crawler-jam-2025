extends Node3D
class_name InteractableBase

#########################################################################
# API.

static var s_interactables : Dictionary = {};

signal on_interact();

#########################################################################
# Internal.

var m_isInteractable : bool = true;

#########################################################################
# Process Order.

func _ready() -> void:
	var pos : Vector2i = Vector2i(floorf(position.x), floorf(position.z));
	Level.s_level.set_cell_item(Vector3i(pos.x, 0, pos.y), Level.s_level.m_fakeFloorIndex)
	
	if (s_interactables.has(pos)): 
		queue_free();
		return;
	s_interactables[pos] = self;

#########################################################################
# Interaction.

static func get_interactable(pos : Vector2i) -> InteractableBase:
	return s_interactables.get(pos, null);

func is_interactable() -> bool:
	return m_isInteractable;

func interact() -> void:
	if (!is_interactable()): return;
	m_isInteractable = false;
	
	interact_internal();
	on_interact.emit();

func interact_internal() -> void:
	assert(false, "Please override `interact_internal()` in the derived script.");

#########################################################################
