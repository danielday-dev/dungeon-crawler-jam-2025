extends SubViewport

# Reference the camera and the player
# "@export" keyword will expose these two variables in the inspector
@export var camera_node : Node3D
@export var player_node : Node3D

var map_cam_position;

func _process(delta: float) -> void:
	# Let camera move with player
	camera_node.set_global_position(map_cam_position.get_global_position())
	camera_node.set_global_rotation(map_cam_position.get_global_rotation())

func _ready() -> void:
	world_3d = get_tree().root.world_3d
	map_cam_position = player_node.map_cam_position
