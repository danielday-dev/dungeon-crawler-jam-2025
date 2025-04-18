@tool
extends GridMap;
class_name GridMapUpdateEmitter;

signal onCellChanged(pos : Vector3);

var m_previousState: Dictionary = {}

var m_undoredo : EditorUndoRedoManager; 

func _ready() -> void:
	m_previousState = captureCurrentState();
	set_process(Engine.is_editor_hint());
	if (!Engine.is_editor_hint()): return;
	
	var dummy_ep = EditorPlugin.new()
	m_undoredo = dummy_ep.get_undo_redo();
	m_undoredo.history_changed.connect(check_changed);
	dummy_ep.free() 

func check_changed() -> void:
	var currentState = captureCurrentState()
	if (detectChanges(m_previousState, currentState)):
		m_previousState = currentState;
	
func captureCurrentState() -> Dictionary:
	var state = {}
	for coord : Vector3i in self.get_used_cells():
		state[coord] = self.get_cell_item(coord)
	return state

func detectChanges(oldState: Dictionary, newState: Dictionary) -> bool:
	var changes = [];
	for coord in newState.keys():
		if not oldState.has(coord) or oldState[coord] != newState[coord]:
			changes.append(coord);
	#
	for coord in oldState.keys():
		if not newState.has(coord):
			changes.append(coord);
	#
	for pos in changes:
		onCellChanged.emit(pos);
	#
	return changes.size() > 0;
