@tool
extends GridMapUpdateEmitter
class_name Level;

static var s_level : Level = null;

var m_floorIndex : int;
var m_fakeFloorIndex : int;
var m_wallIndex : int;
	
func _init() -> void:
	if (s_level != null && !Engine.is_editor_hint()):
		queue_free();
		return;
	s_level = self;

func _ready() -> void:
	#super();
	if (!Engine.is_editor_hint()):
		loadMeshLibrary();
		return;
	
	changed.connect(loadMeshLibrary);
	loadMeshLibrary();
	onCellChanged.connect(cellChanged);
	
func loadMeshLibrary() -> void:
	m_floorIndex = mesh_library.find_item_by_name("Floor");
	m_fakeFloorIndex = mesh_library.find_item_by_name("FAKE_Floor");
	m_wallIndex = mesh_library.find_item_by_name("Wall");

func cellChanged(pos : Vector3i) -> void:
	if (pos.y != 0): return;
	
	const checks : Array[Vector3i] = [
		Vector3i(+1, 0, 0),
		Vector3i(-1, 0, 0),
		Vector3i(0, 0, +1),
		Vector3i(0, 0, -1),
	];
	
	var changedCells : Dictionary = {};
	match (get_cell_item(pos)):
		m_floorIndex:
			for check : Vector3i in checks:
				if (get_cell_item(pos + check) == INVALID_CELL_ITEM):
					changedCells.set(pos + check, [ INVALID_CELL_ITEM, m_wallIndex ]);
		INVALID_CELL_ITEM:
			for check : Vector3i in checks:
				match (get_cell_item(pos + check)):
					m_wallIndex:
						var floorFound : bool = false;
						for nestedCheck : Vector3i in checks: 
							if (get_cell_item(pos + check + nestedCheck) == m_floorIndex):
								floorFound = true;
						if (!floorFound):
							changedCells.set(pos + check, [ m_wallIndex, INVALID_CELL_ITEM ]);
					m_floorIndex:
						changedCells.set(pos, [ INVALID_CELL_ITEM, m_wallIndex ]);

	if (changedCells.is_empty()):
		return;
	
	#m_undoredo.create_action("__AddedWallsToFloor", UndoRedo.MERGE_ALL);
	#for targetPos : Vector3i in changedCells.keys():
		#m_undoredo.add_undo_method(self, "set_wall", targetPos, changedCells.get(targetPos)[0]);
		#m_undoredo.add_do_method(self, "set_wall", targetPos, changedCells.get(targetPos)[1]);
	#m_undoredo.commit_action();

func set_wall(pos : Vector3i, item : int):
	set_cell_item(pos, item);
