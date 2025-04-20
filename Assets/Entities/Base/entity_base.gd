extends GridClient
class_name EntityBase

#########################################################################
# API.

signal on_move_end;
signal on_turn_end;

var m_input_move : Vector2i = Vector2i.ZERO;
var m_input_turn : float = 0.0;
@export var m_max_health: float = 3.0;
@export var m_health: float = 3.0;

#########################################################################
# Internal.

var m_positionCurrent : Vector2i;
var m_positionTarget : Vector2i;
var m_positionLerp : float = 0.0;
@export var m_positionLerpTime : float = 0.5;

var m_turnCurrent : TurnDirection = 0;
var m_turnTarget : TurnDirection;
var m_turnLerp : float = 0.0;
@export var m_turnLerpTime : float = 0.5;

#########################################################################
# Core loop.

func _ready() -> void:
	m_positionCurrent = Vector2i(floorf(position.x), floorf(position.z));
	m_positionTarget = m_positionCurrent;
	m_turnTarget = m_turnCurrent;
	
	update_position_visuals();
	update_turn_visuals();

func _process(delta : float) -> void:
	if (!GameState.in_state(GameState.State.Exploring)): delta = 0;

	if (update_position(delta) || update_turn(delta)): 
		return;

	handle_input();

#########################################################################
# Input handling.

func handle_input() -> void:
	poll_inputs();
	if (handle_turn_input()): return;	
	if (handle_position_input()): return;

func poll_inputs() -> void:
	assert(false, "Please override `poll_inputs()` in the derived script.");
	
func handle_position_input() -> bool:
	if (m_input_move.y != 0):
		m_input_move.x = 0;	
	elif (m_input_move.x == 0):
		return false;
	
	# Set new target.
	var movement : Vector2i = \
		(m_input_move.x * get_turn_right(m_turnCurrent)) + \
		(m_input_move.y * get_turn_forward(m_turnCurrent));
	
	if (is_wall(m_positionTarget + movement)): 
		return false;
	
	m_positionTarget += movement;
	
	return true;
	
func handle_turn_input() -> bool:
	m_turnTarget = posmod(m_turnCurrent + m_input_turn, TurnDirection.Count);
	return is_turning();
	
#########################################################################
# Move processing.

func is_moving() -> bool:
	return m_positionCurrent != m_positionTarget;

func update_position(delta : float) -> bool:
	if (!is_moving()): return false;
	
	if (m_positionLerpTime > 0.0):
		m_positionLerp = move_toward(m_positionLerp, 1.0, delta / m_positionLerpTime);
	else: 
		m_positionLerp = 1.0;
	update_position_visuals();
	
	if (m_positionLerp < 1.0): return true;
	
	m_positionCurrent = m_positionTarget;
	m_positionLerp = 0;
	
	on_move_end.emit();
	return false;

func update_position_visuals() -> void:
	var from := Vector3(m_positionCurrent.x, 0, m_positionCurrent.y);
	var to := Vector3(m_positionTarget.x, 0, m_positionTarget.y);
	position = from.lerp(to, m_positionLerp) + (Vector3.ONE * 0.5);

#########################################################################
# Turn processing.

func is_turning() -> bool:
	return m_turnCurrent != m_turnTarget;
	
func update_turn(delta : float) -> bool:
	if (!is_turning()): return false;
	
	if (m_turnLerpTime > 0.0):
		m_turnLerp = move_toward(m_turnLerp, 1.0, delta / m_turnLerpTime);
	else:
		m_turnLerp = 1.0;
	update_turn_visuals();
	
	if (m_turnLerp < 1.0): return true;
	
	m_turnCurrent = m_turnTarget;
	m_turnLerp = 0;
	
	on_turn_end.emit()
	return false;
	
func update_turn_visuals() -> void:
	var turnFrom := get_turn_angle(m_turnCurrent);
	var turnTo := get_turn_angle(m_turnTarget);
	
	# Correct for wrapping edge case.
	if (m_turnCurrent == TurnDirection.North && m_turnTarget == TurnDirection.East):
		turnFrom += 360.0;
	elif (m_turnCurrent == TurnDirection.East && m_turnTarget == TurnDirection.North): 
		turnFrom -= 360.0;
	
	rotation_degrees.y = lerpf(turnFrom, turnTo, m_turnLerp);

#########################################################################
