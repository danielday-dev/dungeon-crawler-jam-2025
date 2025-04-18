extends Node

enum PlayerState { NONE, DODGE, DODGE_COOLDOWN }
enum Action { ATK_START, ATK_END, WEAK_SPOT, WAIT }

@export var _attackPattern: Array[Action] = [
	Action.ATK_START,
	Action.ATK_END,
	Action.ATK_START,
	Action.ATK_END,
	Action.WEAK_SPOT,
	Action.WAIT
]
@export var _weakSpots: Array[int] = [1]

# dict of attack directions and the corresponding input direction that allows you to dodge successfully
# (the reverse of the attack dir)
var _directions: Dictionary = {
	"UP": Vector2.DOWN,
	"RIGHT": Vector2.LEFT,
	"DOWN": Vector2.UP,
	"LEFT": Vector2.RIGHT
}

var _current_action: Dictionary = {}
var _current_weak_spot: int = 0
var _processed_action = false
var _attack_index: int = 0
var _player_state: PlayerState = PlayerState.NONE
var _dodge_input_direction: Vector2 = Vector2.ZERO
var _time_since_dodge_input: float = 0.0
var _dodge_input_window: float  = 0.5 # dodging within this many seconds of hit will register successfully
var _dodge_input_lockout_time: float = 0.5 # can't dodge again for this many seconds after input

@export var timer: Heartbeat

func _ready() -> void:
	pass
	
func _unhandled_input(event) -> void:
	if event is not InputEventMouseButton:
		return
		
	if !event.pressed || event.button_index != MOUSE_BUTTON_LEFT:
		return
		
	if _current_weak_spot == 0:
		return
		
	print_debug("DEALT DAMAGE")
	_current_weak_spot = 0

func _process(delta: float) -> void:
	
	# if action needs processing, process it
	if _current_action != {} && !_processed_action:
		match _current_action["Type"]:
			Action.WAIT: print_debug("WAITING"); _processed_action = true;
			Action.ATK_START: _attack_windup(delta)
			Action.ATK_END: _attack_hit()
			Action.WEAK_SPOT: _reveal_weak_spot()
			_: pass
		
	# if dodging, store dodge input until window is done
	if (_player_state == PlayerState.DODGE):
		_time_since_dodge_input += delta
		if (_time_since_dodge_input < _dodge_input_window):
			return
		
		# reset stored dodge input, prevent dodging again until small cooldown period done
		_dodge_input_direction = Vector2.ZERO
		_player_state = PlayerState.DODGE_COOLDOWN
	
	# keep counting time elapsed until dodge cooldown is done
	if (_player_state == PlayerState.DODGE_COOLDOWN):
		_time_since_dodge_input += delta
		if (_time_since_dodge_input > _dodge_input_window + _dodge_input_lockout_time):
			_time_since_dodge_input = 0.0
			_player_state = PlayerState.NONE

func _attack_windup(delta: float) -> void:
	if (_player_state == PlayerState.NONE):
		var dodge_input: Vector2 = Input.get_vector("left", "right", "up", "down")
		if (dodge_input == Vector2.ZERO):
			return
		
		_player_state = PlayerState.DODGE
		_dodge_input_direction = dodge_input

func _attack_hit() -> void:
	# if stored dodge input matches required input (inverse of attack direction), dodge else get hit
	if (_dodge_input_direction == _current_action.get("Direction")):
		print_debug("Attack dodged")
	else:	
		print_debug("Attack hit")
	_processed_action = true

func _reveal_weak_spot() -> void:
	_current_weak_spot = _weakSpots.pick_random()
	print_debug("Weak spot revealed")
	_processed_action = true

# all combat actions happen on heartbeat
# enemy attack hit should maybe happen a tiny bit after the heartbeat? to allow player to perfectly time dodge to the beat
# currently you have to dodge BEFORE the beat sound plays
func _on_heartbeat_heart_beat() -> void:
	var nextActionType: Action = _attackPattern.get(_attack_index)
	var attackDirection: Vector2
	
	# carry over direction if it's been set (so we don't lose it going from ATK_START to ATK_END)
	if _current_action.get("Direction", Vector2.ZERO) != Vector2.ZERO:
		attackDirection =_current_action.get("Direction")
	
	if nextActionType == Action.ATK_START:
		attackDirection = _directions.values().pick_random()
		print_debug("Attacking from: " + _directions.find_key(attackDirection))
	
	_current_action = {
		"Type": nextActionType,
		"Direction": attackDirection # vector2 direction of attack
	}
	
	_processed_action = false
	_attack_index += 1
	if _attack_index >= _attackPattern.size(): _attack_index = 0
