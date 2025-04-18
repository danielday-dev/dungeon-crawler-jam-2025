extends Node3D
class_name GridClient

#########################################################################
# Internal.
	
enum TurnDirection {
	North, East, South, West,
	Count,
};
enum PathActions {
	MoveForward,
	TurnLeft, TurnRight,
	Count,
};

#########################################################################
# Helper Functions.

func get_turn_forward(turn : TurnDirection) -> Vector2i:
	match (turn):
		TurnDirection.East: return Vector2i(-1, 0);
		TurnDirection.South: return Vector2i(0, -1);
		TurnDirection.West: return Vector2i(1, 0);
		_: return Vector2i(0, 1);

func get_turn_right(turn : TurnDirection) -> Vector2i:
	match (turn):
		TurnDirection.East: return Vector2i(0, 1);
		TurnDirection.South: return Vector2i(-1, 0);
		TurnDirection.West: return Vector2i(0, -1);
		_: return Vector2i(1, 0);

#########################################################################
# Grid Collision.

func is_wall(pos : Vector2i) -> bool:
	return Level.s_level.get_cell_item(Vector3i(pos.x, 0, pos.y)) != Level.s_level.m_floorIndex;

#########################################################################
# Path finding.

class GridPathNode:	
	var m_parent : GridPathNode;
	var m_pos : Vector2i;
	var m_direction : TurnDirection;
	var m_cost : float;
	var m_heuristic : float;
	
	func _init(parent : GridPathNode, pos : Vector2i, direction : TurnDirection, cost : float, heuristic : float) -> void:
		m_parent = parent;
		m_pos = pos;
		m_direction = direction;
		m_cost = cost;
		m_heuristic = heuristic;
		
func get_grid_path_distance(startPos : Vector2i, endPos : Vector2i) -> float:
	return abs(startPos.x - endPos.x) + abs(startPos.y - endPos.y);

func get_grid_path(startPos : Vector2i, startDirection : TurnDirection, endPos : Vector2i, moveCost : float = 1.0, turnCost : float = 1.0) -> Array[PathActions]:
	if (is_wall(startPos) || is_wall(endPos)):
		return [ 1 if is_wall(startPos) else 0, 1 if is_wall(endPos) else 0 ];
	
	var traversedArr : Array[Dictionary] = [{}, {}, {}, {}];
	var nodes : Array[GridPathNode] = [
		GridPathNode.new(null, startPos, startDirection, 0, 0)
	];
	
	var checks : Array[Vector2i] = [
		get_turn_forward(TurnDirection.North), get_turn_forward(TurnDirection.East),
		get_turn_forward(TurnDirection.South), get_turn_forward(TurnDirection.West),
	];
	
	var nodeBestIndex : int;
	var nodeBestHeuristic : float;
	var node : GridPathNode;
	var backtrackIndex : int;
	var checkPos : Vector2i;
	var checkCost : float;
	var checkHeuristic : float;
	
	while (!nodes.is_empty()):
		# Node selection.
		nodeBestIndex = 0;
		nodeBestHeuristic = nodes[nodeBestIndex].m_heuristic;
		for i : int in range(1, nodes.size()):
			if (nodeBestHeuristic > nodes[i].m_heuristic):
				nodeBestHeuristic = nodes[i].m_heuristic
				nodeBestIndex = i;
		node = nodes[nodeBestIndex];
		nodes.remove_at(nodeBestIndex);
		
		if (traversedArr[node.m_direction].has(node.m_pos) &&
			traversedArr[node.m_direction][node.m_pos] <= node.m_heuristic): continue;
		traversedArr[node.m_direction][node.m_pos] = node.m_heuristic;
		
		# Node end check.
		if (node.m_pos == endPos):
			# TODO: Figure it out.
			var pathParent : GridPathNode = node;
			var pathActions : Array[PathActions] = [];
			while (pathParent != null):
				if (pathParent.m_parent != null):
					if (pathParent.m_pos != pathParent.m_parent.m_pos):
						pathActions.append(PathActions.MoveForward);
					
					if (pathParent.m_direction != pathParent.m_parent.m_direction):
						var turn : int = posmod(pathParent.m_direction - pathParent.m_parent.m_direction, TurnDirection.Count);
						pathActions.append(PathActions.TurnLeft if turn == 3 else PathActions.TurnRight);
				
				pathParent = pathParent.m_parent;
			
			pathActions.reverse();
			return pathActions;
		
		# Node expansion.
		backtrackIndex = (node.m_direction + 2) % TurnDirection.Count;
		for i : int in range(checks.size()):
			# No backtracking.
			if (i == backtrackIndex): continue;
			checkPos = (node.m_pos + checks[i]) if node.m_direction == i else node.m_pos;
			
			# No travelling through walls.
			if (is_wall(checkPos)): continue;
			
			# Get check cost.
			checkCost = node.m_cost;
			if (node.m_pos != checkPos): checkCost += moveCost; # Move cost.
			if (node.m_direction != i): checkCost += turnCost; # Turn cost.
			
			# Compare heuristics.
			checkHeuristic = get_grid_path_distance(checkPos, endPos) + checkCost;
			
			# Check if already traversed better.
			if (traversedArr[i].has(checkPos) &&
				traversedArr[i][checkPos] <= checkHeuristic): continue;
			
			nodes.append(GridPathNode.new(
				node, checkPos, i, checkCost, checkHeuristic
			));
		
	return [];
