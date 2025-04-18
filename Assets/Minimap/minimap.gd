extends SubViewport

@export var camera_node : Node3D

func _process(delta: float) -> void:
	if (Player.s_instance == null): return;
	camera_node.set_global_position(Player.s_instance.map_cam_position.get_global_position())
	camera_node.set_global_rotation(Player.s_instance.map_cam_position.get_global_rotation())

func _ready() -> void:
	world_3d = get_tree().root.world_3d
