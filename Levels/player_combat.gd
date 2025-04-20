extends Node3D

@export var testEnemy: Node3D;
@export var dodgeCurve: Curve;
@onready var head = $Head;

var m_cam_original_pos: Vector3;
var m_look_at_enemy: Vector3 = Vector3.ZERO;
var m_enemy_pos_lerped: Vector3;
var m_time_lerp: float = 0.0;
var m_dodging_direction: Vector2 = Vector2.ZERO;
var m_dodge_distance: float = 0.5;

func _ready() -> void:
	m_cam_original_pos = head.position;
	_on_combat_enter(testEnemy.global_position);

func _on_combat_enter(enemyPos: Vector3) -> void:
	head.look_at(enemyPos);

func _process(delta: float) -> void:
	_dodge_direction(delta);

func _dodge_direction(delta: float) -> void:
	if (m_dodging_direction == Vector2.ZERO):
		return;
	
	var curve_value: float = dodgeCurve.sample(m_time_lerp) * m_dodge_distance;
	head.position = m_cam_original_pos + Vector3(m_dodging_direction.x * curve_value, m_dodging_direction.y * -curve_value, 0.0);
	m_time_lerp += delta;
	
	if (m_time_lerp >= 1.0):
		m_dodging_direction = Vector2.ZERO;
		m_time_lerp = 0.0;

func _on_combat_dodge(direction: Vector2) -> void:
	m_dodging_direction = direction;
