extends ProgressBar

func _process(delta: float) -> void:
	value = (Player.s_instance.m_health / Player.s_instance.m_max_health) * 100
