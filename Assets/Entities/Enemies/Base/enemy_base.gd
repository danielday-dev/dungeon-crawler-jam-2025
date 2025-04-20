extends EntityBase

@export var m_engage_path_length_threshold : float = 2.0;
var m_engage_path_wait : int = 0;
var m_path : Array[PathActions] = [];

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
		
	# TODO: It would be all coolios to check line-of-sight with the player here.
