@tool
extends Node
class_name ClearManager;
static var s_instance : ClearManager = null;

#########################################################################

@export var s_material : ShaderMaterial;

#########################################################################

var m_updated : bool = false;

#########################################################################

func _ready() -> void:
	if (s_instance != null && s_instance != self):
		queue_free();
		return;
	s_instance = self;
	set_process(true);
	
	child_order_changed.connect(update_material);
	
	update_material();

func _process(_delta: float) -> void:
	if (!m_updated): return;
	m_updated = false;
	update_material();
	
#########################################################################
	
func update_material() -> void:
	var clearPositions : Array[Vector3] = [];
	var clearRange : Array[float] = [];
	
	for child : ClearNode in get_children():
		if (child == null): continue;
		clearPositions.append(child.global_position);
		clearRange.append(child.m_clearRange);
	
	s_material.set_shader_parameter("u_clearCenters", clearPositions);
	s_material.set_shader_parameter("u_clearRange", clearRange);
	s_material.set_shader_parameter("u_clearCount", min(32, clearPositions.size(), clearRange.size()));

#########################################################################
