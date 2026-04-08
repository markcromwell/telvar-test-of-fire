extends Node
## Drives [member Player.queued_direction] toward the nearest remaining spell page using grid BFS on the level maze.

const TILE_SIZE: int = 48

@export var player: CharacterBody2D
## Typically the level's [code]SpellPages[/code] node (see [code]LevelBase[/code] / level scenes).
@export var pages_container: Node2D
## Level node with [method LevelBase.get_maze_layout] (defaults to parent).
@export var level_root: Node = null

var _grid_dirs: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
]


func _ready() -> void:
	# Run before [member Player._physics_process] so queued direction is set before input is read.
	process_physics_priority = -100


func _physics_process(_delta: float) -> void:
	if player == null or pages_container == null:
		return
	if not player.is_alive:
		return
	var lvl: Node = level_root if level_root != null else get_parent()
	if lvl == null or not lvl.has_method("get_maze_layout"):
		return
	var layout: PackedStringArray = lvl.call("get_maze_layout") as PackedStringArray
	if layout.is_empty():
		return
	var nearest: Vector2 = _nearest_page_global(layout)
	if nearest == Vector2.ZERO:
		return
	var goal_tile := _world_to_tile(nearest)
	var start_tile := _player_tile()
	var next_tile := _first_step_on_path(start_tile, goal_tile, layout)
	if next_tile == start_tile:
		return
	var step := next_tile - start_tile
	player.queued_direction = Vector2(float(step.x), float(step.y)).normalized()


func _nearest_page_global(layout: PackedStringArray) -> Vector2:
	var start: Vector2i = _player_tile()
	var best: Vector2 = Vector2.ZERO
	var best_d: int = 999999
	for child in pages_container.get_children():
		if not is_instance_valid(child):
			continue
		if not (child is Node2D):
			continue
		var n2 := child as Node2D
		var gt: Vector2i = _world_to_tile(n2.global_position)
		var d: int = _bfs_distance(start, gt, layout)
		if d >= 0 and d < best_d:
			best_d = d
			best = n2.global_position
	return best


func _player_tile() -> Vector2i:
	var pos: Vector2 = player.global_position
	if "is_moving" in player and player.is_moving and "target_position" in player:
		pos = player.target_position
	return _world_to_tile(pos)


func _world_to_tile(world: Vector2) -> Vector2i:
	# Align with maze grid: cell (col, row) covers [col*TILE, (col+1)*TILE).
	return Vector2i(int(floor(world.x / float(TILE_SIZE))), int(floor(world.y / float(TILE_SIZE))))


func _walkable(t: Vector2i, layout: PackedStringArray) -> bool:
	if t.y < 0 or t.y >= layout.size():
		return false
	var row: String = layout[t.y]
	if t.x < 0 or t.x >= row.length():
		return false
	return row[t.x] != "#"


func _bfs_distance(from: Vector2i, goal: Vector2i, layout: PackedStringArray) -> int:
	if from == goal:
		return 0
	if not _walkable(from, layout) or not _walkable(goal, layout):
		return -1
	var q: Array[Vector2i] = [from]
	var depth: Dictionary = {from: 0}
	while not q.is_empty():
		var cur: Vector2i = q.pop_front()
		var cur_d: int = depth[cur]
		for off in _grid_dirs:
			var nxt: Vector2i = cur + off
			if not _walkable(nxt, layout):
				continue
			if depth.has(nxt):
				continue
			depth[nxt] = cur_d + 1
			if nxt == goal:
				return cur_d + 1
			q.append(nxt)
	return -1


func _first_step_on_path(from: Vector2i, goal: Vector2i, layout: PackedStringArray) -> Vector2i:
	if from == goal:
		return from
	if not _walkable(from, layout) or not _walkable(goal, layout):
		return from
	var q: Array[Vector2i] = [from]
	var visited: Dictionary = {from: true}
	var parent: Dictionary = {}
	while not q.is_empty():
		var cur: Vector2i = q.pop_front()
		for off in _grid_dirs:
			var nxt: Vector2i = cur + off
			if not _walkable(nxt, layout):
				continue
			if visited.has(nxt):
				continue
			visited[nxt] = true
			parent[nxt] = cur
			if nxt == goal:
				var step: Vector2i = nxt
				while parent.has(step) and parent[step] != from:
					step = parent[step]
				return step
			q.append(nxt)
	return from
