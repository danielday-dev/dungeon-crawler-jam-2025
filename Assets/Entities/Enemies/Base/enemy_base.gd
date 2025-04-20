extends EntityBase
class_name EnemyBase;

@export var m_engage_path_length_threshold : float = 2.0;
var m_engage_path_wait : int = 0;
var m_path : Array[PathActions] = [];

@export var m_weakSpotsParent : Node3D;
@export var m_cameraParent : Node3D;

func _ready() -> void:
	super();
	#
	Player.s_instance.on_move_end.connect(updatePath);

func poll_inputs() -> void:
	if (is_moving() || is_turning()): return;
	if (m_path.is_empty()): return;
	
	m_input_move = Vector2i.ZERO;
	m_input_turn = 0;
	match (m_path.pop_front()):
		PathActions.MoveForward: 
			m_input_move = Vector2i(0, 1);
		PathActions.TurnLeft: 
			m_input_turn = -1;
		PathActions.TurnRight: 
			m_input_turn = 1;

func updatePath() -> void:
	if (m_engage_path_wait > 0):
		m_engage_path_wait -= 1;
		return;
	
	m_path = get_grid_path(m_positionTarget, m_turnTarget, Player.s_instance.m_positionTarget, m_positionLerpTime, m_turnLerpTime);
	
	var pathMoves : int = 0;
	var pathTurns : int = 0;
	for pathAction : PathActions in m_path:
		match (pathAction):
			PathActions.MoveForward: pathMoves += 1;
			PathActions.TurnLeft, PathActions.TurnRight: pathTurns += 1;

	var pathLength : float = (float(pathMoves) * m_positionLerpTime) + (float(pathTurns) * m_turnLerpTime);
	if (pathLength > m_engage_path_length_threshold): 
		m_path.clear();
		return;

#Combat animation
@export var takeHitCurve: Curve;
var m_original_pos: Vector3;
var m_taken_hit: bool = false;
var m_hit_lerp: float = 0.0;
var m_hit_distance: float = 0.15;

func _take_hit(delta: float) -> void:
	if (!m_taken_hit):
		return;
	
	var curve_value: float = takeHitCurve.sample(m_hit_lerp) * m_hit_distance;
	position = m_original_pos - Vector3(0.0, 0.0, curve_value);
	m_hit_lerp += delta;
	
	if (m_hit_lerp >= 1.0):
		m_taken_hit = false;
		m_hit_lerp = 0.0;

func _on_combat_hit() -> void:
	m_original_pos = position;
	m_taken_hit = true;
		
	# TODO: It would be all coolios to check line-of-sight with the player here.
