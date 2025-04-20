extends Node2D

class_name Gun

@onready var _gun: AnimatedSprite2D = $Gun;
@onready var _cursor: Sprite2D = $Cursor;

@export var _gun_follow_speed: float = 640.0 * 2.0;

var _combat_active: bool = false;
var _screen_size: Vector2;

func _ready() -> void:
	_screen_size = get_viewport_rect().size;
	_gun.speed_scale = 0;

func _process(delta: float) -> void:
	
	if (!_combat_active):
		return;
	
	var mouse_pos: Vector2 = get_global_mouse_position();
	var target_position: Vector2 = mouse_pos - (_screen_size / 2);
	_gun.position = _gun.position.move_toward(target_position, delta * _gun_follow_speed);
	_cursor.position = mouse_pos;
	
func _set_combat_active(active: bool = false) -> void:
	_combat_active = active;
	_cursor.visible = active;
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if active else Input.MOUSE_MODE_VISIBLE;

func _shoot() -> void:
	_gun.speed_scale = 1;
	_gun.play();
