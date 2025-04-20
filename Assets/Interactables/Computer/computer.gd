extends InteractableBase

@export var m_targetClearRange : float = 7.0;
@export var m_targetClearRate : float = 0.9;

func _process(delta: float) -> void:
	if (m_isInteractable): return;
	$ClearNode.m_clearRange = clampf($ClearNode.m_clearRange + (m_targetClearRate * delta), $ClearNode.m_clearRange, m_targetClearRange);

func interact_internal() -> void:
	return;
