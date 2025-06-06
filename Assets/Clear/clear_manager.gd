@tool
extends Node
class_name ClearManager;
static var s_instance : ClearManager = null;

#########################################################################

@export var s_material : ShaderMaterial;

var m_updated : bool = false;

#########################################################################

func _init() -> void:
	if (s_instance != null && !Engine.is_editor_hint()):
		queue_free();
		return;
	s_instance = self;
	
func _ready() -> void:
	set_process(true);	
	update_material();

func _process(_delta : float) -> void:
	if (!m_updated): return;
	m_updated = false;
	update_material();
	
#########################################################################

func update_material() -> void:
	var clearPositions : Array[Vector3] = [];
	var clearRange : Array[float] = [];
	
	for node : ClearNode in get_tree().get_nodes_in_group("ClearNodes"):
		if (clearPositions.size() >= 32): break;
		if (node == null): continue;
		clearPositions.append(node.global_position);
		clearRange.append(node.m_clearRange);

	s_material.set_shader_parameter("u_clearCenters", clearPositions);
	s_material.set_shader_parameter("u_clearRange", clearRange);
	s_material.set_shader_parameter("u_clearCount", min(32, clearPositions.size(), clearRange.size()));

#########################################################################
