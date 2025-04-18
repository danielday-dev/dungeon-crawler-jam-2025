extends Node2D

@onready var _gun: Node2D = $Gun
@onready var _cursor: Node2D = $Cursor

@export var _gun_follow_speed: float = 640.0 * 2.0

var _screen_size: Vector2;

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var target_position: Vector2 = mouse_pos - (_screen_size / 2)
	_gun.position = _gun.position.move_toward(target_position, delta * _gun_follow_speed)
	_cursor.position = mouse_pos
