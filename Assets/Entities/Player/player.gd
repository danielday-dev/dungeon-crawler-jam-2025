extends EntityBase
class_name Player;

static var s_instance : Player = null;

@onready var head : Node3D = $Head
@onready var camera : Camera3D = $Head/FirstPersonCamera
@onready var map_cam_position : Node3D = $Head/MapCameraPos

func _init() -> void:
	if (s_instance != null):
		queue_free();
		return;
	s_instance = self;

func poll_inputs() -> void:
	m_input_move = Vector2i(
		ceilf(Input.get_axis("right", "left")),
		ceilf(Input.get_axis("down", "up"))
	);
	m_input_turn = Input.get_axis("look_left", "look_right");
