extends Node3D

@export var _player: Node3D

func _process(delta: float) -> void:
	var target = _player.head.position
	look_at(target, Vector3.UP)
