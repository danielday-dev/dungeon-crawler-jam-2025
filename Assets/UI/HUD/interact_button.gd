extends Button

func _ready() -> void:
	pressed.connect(use_interactable);

func _process(delta: float) -> void:
	var interactable : InteractableBase = get_interactable();
	visible = interactable != null;

func get_interactable() -> InteractableBase:
	if (Player.s_instance == null): return null
	if (Player.s_instance.is_moving() || Player.s_instance.is_turning()): return null;
	return InteractableBase.get_interactable(Player.s_instance.m_positionCurrent + Player.s_instance.get_turn_forward(Player.s_instance.m_turnCurrent));
	
func use_interactable(): 
	var interactable : InteractableBase = get_interactable();
	if (interactable == null): return;
	interactable.interact();
