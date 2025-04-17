extends SubViewport

@export var camera_node : Node3D
@export var player_node : Player

var map_cam_position;

func _process(delta: float) -> void:
	camera_node.set_global_position(map_cam_position.get_global_position())
	camera_node.set_global_rotation(map_cam_position.get_global_rotation())

func _ready() -> void:
	map_cam_position = player_node.map_cam_position
