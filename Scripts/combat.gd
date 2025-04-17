extends Node

enum Action { ATK_START, ATK_END, WEAK_SPOT, WAIT }
enum WeakSpot { HEAD, ARM_RIGHT, ARM_LEFT, BODY, LEG_RIGHT, LEG_LEFT }

var _directions: Array = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var _action: Dictionary = {}
var _attackPattern: Array[Action] = [
	Action.ATK_START,
	Action.ATK_END,
	Action.ATK_START,
	Action.ATK_END,
	Action.WEAK_SPOT,
	Action.WAIT
]
var _attack_index: int = 0
var _weakSpots: WeakSpot
var _dodge_input_direction: Vector2 = Vector2.ZERO
var _time_since_dodge_input: float = 0.0
var _dodge_input_lockout_time: float = 0.5 # can't dodge again for this many seconds after input

@export var timer: Heartbeat

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if _action == {}:
		return

	match _action["Type"]:
		Action.WAIT: pass
		Action.ATK_START: _attack_windup(delta)
		Action.ATK_END: _attack_hit()
		Action.WEAK_SPOT: _reveal_weak_spot()
		_: pass

func _attack_windup(delta: float) -> void:
	if (_dodge_input_direction == Vector2.ZERO):
		var dodge_input: Vector2 = Input.get_vector("left", "right", "up", "down")
		if (dodge_input == Vector2.ZERO):
			return
		_dodge_input_direction = dodge_input
		_time_since_dodge_input = 0.0
	
	_time_since_dodge_input += delta
	if (_time_since_dodge_input < _dodge_input_lockout_time):
		return

func _attack_hit() -> void:
	print_debug("Attack hit")
	_action = {}

func _reveal_weak_spot() -> void:
	print_debug("Weak spot revealed")
	_action = {}

func _on_heartbeat_heart_beat() -> void:
	var nextActionType: Action = _attackPattern.get(_attack_index)
	var attackDirection: Vector2
	
	if nextActionType == Action.ATK_START:
		attackDirection = _directions.pick_random()
		print_debug("Attacking from: " + str(attackDirection))
		
	_action = {
		"Type": nextActionType,
		"Direction": attackDirection
		}
		
	_attack_index += 1
	if _attack_index >= _attackPattern.size(): _attack_index = 0
