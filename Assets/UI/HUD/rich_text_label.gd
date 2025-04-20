extends RichTextLabel

func _process(delta: float) -> void:
	text = str(Player.s_instance.m_health) + "/" + str(Player.s_instance.m_max_health);
