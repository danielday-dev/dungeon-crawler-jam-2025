@tool
extends Node3D
class_name ClearNode;

#########################################################################

@export var m_clearRange : float:
	get():
		return m_clearRange;
	set(value):
		m_clearRange = value;
		update_material();
var m_lastPosition : Vector3;

#########################################################################

func _ready():
	m_lastPosition = global_position;
	update_material();
	set_process(true);
	add_to_group("ClearNodes");

func _exit_tree() -> void:
	update_material();

func _physics_process(delta: float) -> void:
	if (m_lastPosition == global_position): return;
	m_lastPosition = global_position;
	update_material();
	
#########################################################################

func update_material():
	if (ClearManager.s_instance == null): return;
	ClearManager.s_instance.m_updated = true;
	
#########################################################################
