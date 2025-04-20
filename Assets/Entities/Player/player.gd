extends EntityBase
class_name Player;

static var s_instance : Player = null;

@onready var head : Node3D = $Head
@onready var cameraTransform : Node3D = $Head/CameraTransform
@onready var camera : Camera3D = $Head/CameraTransform/FirstPersonCamera
@onready var map_cam_position : Node3D = $Head/MapCameraPos
@export var dodgeCurve: Curve;
@export var timer: Heartbeat;

var m_cam_original_pos: Vector3;
var m_dodge_lerp: float = 0.0;
var m_dodging_direction: Vector2 = Vector2.ZERO;
var m_dodge_distance: float = 0.25;
var damage = 1.0;


func _init() -> void:
	if (s_instance != null && !Engine.is_editor_hint()):
		queue_free();
		return;
	s_instance = self;
	
	m_turnCurrent = TurnDirection.South;

func _ready() -> void:
	super();
	m_cam_original_pos = head.position;

func _process(delta: float) -> void:
	super(delta);
	_dodge_direction(delta);
	_take_hit(delta);

func poll_inputs() -> void:
	m_input_move = Vector2i(
		ceilf(Input.get_axis("right", "left")),
		ceilf(Input.get_axis("down", "up"))
	);
	m_input_turn = Input.get_axis("look_left", "look_right");

func _on_combat_start_area_entered(area: Area3D) -> void:
	GameState.s_instance.set_state(GameState.State.Combat);
	Combat.s_instance._start_combat(area.get_parent());

func _dodge_direction(delta: float) -> void:
	if (m_dodging_direction == Vector2.ZERO):
		return;
	
	var curve_value: float = dodgeCurve.sample(m_dodge_lerp) * m_dodge_distance;
	head.position = m_cam_original_pos + Vector3(m_dodging_direction.x * curve_value, m_dodging_direction.y * curve_value, 0.0);
	m_dodge_lerp += delta;
	
	if (m_dodge_lerp >= 1.0):
		m_dodging_direction = Vector2.ZERO;
		m_dodge_lerp = 0.0;

func _on_combat_dodge(direction: Vector2) -> void:
	m_dodging_direction = -direction;	

#Combat animation
@export var takeHitCurve: Curve;
var m_taken_hit: bool = false;
var m_hit_lerp: float = 0.0;
var m_hit_distance: float = 0.15;

func _take_hit(delta: float) -> void:
	if (!m_taken_hit):
		return;
	
	var curve_value: float = takeHitCurve.sample(m_hit_lerp) * m_hit_distance;
	head.position = m_cam_original_pos + Vector3(0.0, 0.0, -curve_value);
	m_hit_lerp += delta;
	
	if (m_hit_lerp >= 1.0):
		m_taken_hit = false;
		m_hit_lerp = 0.0;

func _on_combat_hit() -> void:
	m_taken_hit = true;
