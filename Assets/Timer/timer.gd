extends Node

class_name Heartbeat

@onready var _audio_source = $AudioStreamPlayer
@export var _text : RichTextLabel

var _time_left : float = 5.0 * 60.0;
var _base_bpm := 30.0
var _bpm := 30.0
var _time_since_last_beat = 0.0

signal heart_beat

func _process(delta: float) -> void:
	_update_timer(delta)
	_heartbeat(delta)

func _update_timer(delta: float) -> void:
	var bpm_modifier = _bpm / _base_bpm
	_time_left -= delta * bpm_modifier
	var mins = floor(_time_left / 60.0)
	var secs = _time_left - (mins * 60.0)
	_text.text = "%02d: %02d" % [mins, secs]

func _heartbeat(delta: float) -> void:
	_time_since_last_beat += delta
	var bps = 60.0 / _bpm
	if (_time_since_last_beat >= bps):
		_play_heartbeat()
		_time_since_last_beat -= bps

func _play_heartbeat() -> void:
	_audio_source.play()
	heart_beat.emit()
