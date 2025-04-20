extends Node
class_name GameState

#########################################################################
# API.

@export var s_material : ShaderMaterial;
static var s_activeState := State.Exploring;
static var s_instance : GameState;

#########################################################################
# Internals.

enum State {
	Transitioning,
	
	Exploring,
	Combat,
};

var m_stateCurrent : State = s_activeState;
@onready var m_stateTarget : State = m_stateCurrent;
var m_stateTransitionLerp : float = 0;
@export var m_stateTransitionTime : float = 0.5;

@export var m_combatRange : float = 5.0;

#########################################################################
# Process.

func _init() -> void:
	if (s_instance != null && !Engine.is_editor_hint()):
		queue_free();
		return;
	s_instance = self;

func _process(delta : float) -> void:
	s_activeState = State.Transitioning if is_transitioning() else m_stateCurrent;
	update_state(delta);

#########################################################################
# Static State.

static func in_state(state : State) -> bool:
	return s_activeState == state;
	
#########################################################################
# State.

func is_transitioning() -> bool:
	return m_stateCurrent != m_stateTarget;

func set_state(state : State) -> void:
	if (is_transitioning()): return;
	m_stateTarget = state;
	
func update_state(delta):
	if (!is_transitioning()): return;
	
	if (m_stateTransitionTime > 0):
		m_stateTransitionLerp = move_toward(m_stateTransitionLerp, 1.0, delta / m_stateTransitionTime);
	else:
		m_stateTransitionLerp = 1.0;
	update_state_visuals();
	
	if (m_stateTransitionLerp < 1.0): return;
	
	m_stateCurrent = m_stateTarget;

func update_state_visuals() -> void:
	if (Player.s_instance == null): return;

	var combatRange : float = \
		m_stateTransitionLerp if (m_stateTarget == State.Combat) else \
		(1.0 - m_stateTransitionLerp) if (m_stateCurrent) else \
		0.0;
	combatRange *= m_combatRange;
	combatRange *= combatRange;
	
	s_material.set_shader_parameter("u_combatCenter", Player.s_instance.global_position);
	s_material.set_shader_parameter("u_combatRange", combatRange);

#########################################################################
