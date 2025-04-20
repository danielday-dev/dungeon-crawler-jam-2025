extends Sprite3D

@export var _timer: Heartbeat;

var _ring_size = 1.0;
var _weakspot_size = 0.2;

func _ready() -> void:
	scale = Vector3(_ring_size, _ring_size, 1);
	visible = false;

func _process(delta: float) -> void:
	if (!visible):
		return;
	
	var ring_scale: float = move_toward(_ring_size, _weakspot_size, (_timer._time_since_last_beat / _timer._bps) * (_ring_size - _weakspot_size));
	scale = Vector3(ring_scale, ring_scale, 1);

func _set_ring_visible(setVisible: bool = true):
	visible = setVisible;
	scale = Vector3(_ring_size, _ring_size, 1);

# Reveal weak spot
func _on_combat_weak_spot_reveal() -> void:
	_set_ring_visible(true);

# Hide weak spot
func _on_heartbeat_heart_beat() -> void:
	_set_ring_visible(false);
