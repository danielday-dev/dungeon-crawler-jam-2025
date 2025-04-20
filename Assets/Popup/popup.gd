extends Label
class_name TextPopup;
static var s_instance : TextPopup = null;

var m_duration : float = 3.0;
var m_opacity : float = 0.0;

func _init() -> void:
	if (s_instance != null):
		queue_free();
		return;
	s_instance = self;

func _process(delta: float) -> void:
	m_opacity = move_toward(m_opacity, 0, delta / m_duration);
	modulate.a = m_opacity;

func set_popup_text(text_str : String) -> void:
	text = text_str;
	m_opacity = 1.0;
