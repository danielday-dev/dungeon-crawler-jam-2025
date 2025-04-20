extends Node
class_name Combat;
static var s_instance : Combat = null;

enum PlayerState { NONE, DODGE, DODGE_COOLDOWN };
enum Action { ATK_START, ATK_END, WEAK_SPOT, WAIT };

@onready var _gun: Gun = $Gun;
var cam: Camera3D;

@export var _timer: Heartbeat;
@export var _attackRing: TargetingRing;
@export var _attackPattern: Array[Action] = [
	Action.ATK_START,
	Action.ATK_END,
	Action.ATK_START,
	Action.ATK_END,
	Action.WEAK_SPOT,
	Action.WAIT
];
@export var _attackIndicatorsParent: Node;

signal weak_spot_reveal;
signal dodge(direction: Vector2);

# dict of attack directions and the corresponding input direction that allows you to dodge successfully
# (the reverse of the attack dir)
var _directions: Array[Vector2] = [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT];
var _weak_spots: Array[Sprite3D];
var _attack_indicators: Array[TextureRect]

var _current_action: Dictionary = {};
var _current_weak_spot: Sprite3D;
var _processed_action = false;
var _attack_index: int = 0;
var _player_state: PlayerState = PlayerState.NONE;
var _dodge_input_direction: Vector2 = Vector2.ZERO;
var _time_since_dodge_input: float = 0.0;
var _dodge_input_window: float  = 0.25; # dodging within this many seconds of hit will register successfully
var _dodge_input_lockout_time: float = 1.0; # can't dodge again for this many seconds after input
var _check_click_hit_weak_spot: bool = false;
var _shoot_input_window: float = 0.25;

var m_initializedCombat : bool = false;
var m_enemy : EnemyBase = null;

func _init() -> void:
	if (s_instance != null):
		queue_free();
		return;
	s_instance = self;

func _ready() -> void:
	_attack_indicators.assign(_attackIndicatorsParent.find_children("*", "TextureRect", true, false));
	cam = get_viewport().get_camera_3d();
	
func _start_combat(enemy : EnemyBase):
	if (enemy == null): return;
	m_enemy = enemy;
	_weak_spots.assign(m_enemy.m_weakSpotsParent.find_children("*", "Sprite3D", true, false));
	
	_set_visible_indicators();
	_set_visible_weak_spots();
	_gun._set_combat_active(true);
	$Gun.visible = true;
	
	_timer.heart_beat.connect(_on_heartbeat_heart_beat);
	_timer.heart_beat.connect(_attackRing._on_heartbeat_heart_beat);
	weak_spot_reveal.connect(_attackRing._on_combat_weak_spot_reveal);
	
	m_initializedCombat = true;
	
func _clear_combat():
	_weak_spots.clear();
	
	_set_visible_indicators();
	_set_visible_weak_spots();
	_gun._set_combat_active(false);
	$Gun.visible = false;
	
	_timer.heart_beat.disconnect(_on_heartbeat_heart_beat);
	_timer.heart_beat.disconnect(_attackRing._on_heartbeat_heart_beat);
	weak_spot_reveal.disconnect(_attackRing._on_combat_weak_spot_reveal);
	
func _unhandled_input(event) -> void:
	if event is not InputEventMouseButton:
		return;
		
	if !event.pressed || event.button_index != MOUSE_BUTTON_LEFT:
		return;
		
	if _current_weak_spot == null:
		return;
	
	_gun._shoot();
	_check_click_hit_weak_spot = true;

func _physics_process(delta):
	if (!_check_click_hit_weak_spot):
		return;
	
	_check_click_hit_weak_spot = false;
	var space_state = get_tree().root.get_world_3d().direct_space_state;
	var mousepos = get_viewport().get_mouse_position();

	var origin = cam.project_ray_origin(mousepos);
	var end = origin + cam.project_ray_normal(mousepos) * 1000.0;
	var query = PhysicsRayQueryParameters3D.create(origin, end);
	query.collide_with_areas = true;

	var result = space_state.intersect_ray(query);
	if !result:
		print_debug("Missed weak spot")
		return;
	
	print_debug("Hit weak spot");
	
	_set_visible_weak_spots()
	_current_weak_spot = null;
	
	if (_timer._bps - _timer._time_since_last_beat > _shoot_input_window):
		print_debug("Shot too early...")
	
func _process(delta: float) -> void:
	if (!GameState.in_state(GameState.State.Combat)): 
		if (!GameState.in_state(GameState.State.Transitioning) && m_initializedCombat):
			_clear_combat();
			m_initializedCombat = false;
		return;
	if (!m_initializedCombat): return;
	
	# if action needs processing, process it
	if _current_action != {} && !_processed_action:
		match _current_action["Type"]:
			Action.WAIT: _wait();
			Action.ATK_START: _attack_windup(delta);
			Action.ATK_END: _attack_hit();
			Action.WEAK_SPOT: _reveal_weak_spot();
			_: pass;
		
	# if dodging, store dodge input until window is done
	if (_player_state == PlayerState.DODGE):
		_time_since_dodge_input += delta;
		if (_time_since_dodge_input < _dodge_input_window):
			return;
		
		dodge.emit(_dodge_input_direction);
		
		# reset stored dodge input, prevent dodging again until small cooldown period done
		_dodge_input_direction = Vector2.ZERO;
		_player_state = PlayerState.DODGE_COOLDOWN;
	
	# keep counting time elapsed until dodge cooldown is done
	if (_player_state == PlayerState.DODGE_COOLDOWN):
		_time_since_dodge_input += delta;
		if (_time_since_dodge_input > _dodge_input_window + _dodge_input_lockout_time):
			_time_since_dodge_input = 0.0;
			_player_state = PlayerState.NONE;





func _wait() -> void:
	print_debug("WAITING");
	_set_visible_weak_spots();
	_processed_action = true;

func _attack_windup(delta: float) -> void:
	if (_player_state == PlayerState.NONE):
		var dodge_input: Vector2 = Input.get_vector("left", "right", "up", "down");
		if (dodge_input == Vector2.ZERO):
			return;
		
		_player_state = PlayerState.DODGE;
		_dodge_input_direction = dodge_input;

func _attack_hit() -> void:
	# if stored dodge input matches required input (inverse of attack direction), dodge else get hit
	if (_dodge_input_direction == _current_action.get("Direction")):
		print_debug("Attack dodged");
	else:
		print_debug("Attack hit");
	_set_visible_indicators();
	_processed_action = true;

func _reveal_weak_spot() -> void:
	var rand = randi_range(0, _weak_spots.size() - 1);
	_current_weak_spot = _weak_spots[rand];
	_set_visible_weak_spots(rand);
	#var weakspotPos = cam.unproject_position(_current_weak_spot.global_position);
	#print_debug(weakspotPos);
	#_attackRing.set_position(weakspotPos);
	_attackRing.set_global_position(_current_weak_spot.global_position);
	print_debug("Weak spot revealed");
	_processed_action = true;
	weak_spot_reveal.emit();

func _set_visible_weak_spots(active: int = -1) -> void:
	for i in range(0, _weak_spots.size()):
		_weak_spots[i].visible = (i == active)

func _set_visible_indicators(active: int = -1) -> void:
	for i in range(0, _directions.size()):
		_attack_indicators[i].visible = (i == active);

# all combat actions happen on heartbeat
# enemy attack hit should maybe happen a tiny bit after the heartbeat? to allow player to perfectly time dodge to the beat
# currently you have to dodge BEFORE the beat sound plays
func _on_heartbeat_heart_beat() -> void:
	var nextActionType: Action = _attackPattern.get(_attack_index);
	var attackDirection: Vector2;
	
	# carry over direction if it's been set (so we don't lose it going from ATK_START to ATK_END)
	if _current_action.get("Direction", Vector2.ZERO) != Vector2.ZERO:
		attackDirection =_current_action.get("Direction");
	
	if nextActionType == Action.ATK_START:
		var rand = randi_range(0, _directions.size() - 1);
		attackDirection = _directions[rand];
		_set_visible_indicators(rand);
	
	_current_action = {
		"Type": nextActionType,
		"Direction": attackDirection # vector2 direction of attack
	};
	
	_processed_action = false;
	_attack_index += 1;
	if _attack_index >= _attackPattern.size():
		_attack_index = 0;
