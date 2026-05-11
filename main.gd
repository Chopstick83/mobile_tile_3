extends Node2D

@export var tile_scene: PackedScene # 인스턴스화할 타일 씬
@export var board_width: int = 8
@export var board_height: int = 8
@export var board_depth: int = 3 # 층의 개수 (z축)

var tiles: Array # 3D 배열로 전체 타일 데이터 저장 (grid_z, grid_y, grid_x)
var active_tiles: Array[Node] # 현재 보드에 실제 존재하는 타일 노드들을 저장
var selected_tiles: Array = [] # 현재 선택된 타일들을 저장 (매치3 등)

func _ready():
	_initialize_board()
	_populate_board()

func _initialize_board():
	tiles.resize(board_depth)
	for z in range(board_depth):
		tiles[z] = []
		tiles[z].resize(board_height)
		for y in range(board_height):
			tiles[z][y] = []
			tiles[z][y].resize(board_width)
			for x in range(board_width):
				tiles[z][y][x] = -1 # -1은 타일 없음, 실제로는 타일 ID

func _populate_board():
	for z in range(board_depth):
		for y in range(board_height):
			for x in range(board_width):
				var tile_id = [0, 3, 6, 9, 12].pick_random() # 타일 이미지 Index 
				_create_tile(x, y, z, tile_id)

func _create_tile(x: int, y: int, z: int, id: int):
	var tile_instance = tile_scene.instantiate() as Area2D
	add_child(tile_instance)
	tile_instance.init_tile(x, y, z, id)
	tile_instance.connect("tile_clicked", _on_tile_clicked)
	tiles[z][y][x] = id # 그리드 데이터에 ID 저장 (또는 타일 노드 자체를 저장)
	active_tiles.append(tile_instance)

func _on_tile_clicked(tile_data: Dictionary):
	var x = tile_data.x
	var y = tile_data.y
	var z = tile_data.z
	var tile_node = tile_data.node

	if not _can_access_tile(x, y, z):
		print("Tile at (%d, %d, %d) is blocked!" % [x, y, z])
		return

	print("Tile at (%d, %d, %d) with ID %d clicked!" % [x, y, z, tile_data.id])

	if selected_tiles.size() < 2:
		selected_tiles.append(tile_data)
		tile_node.select_tile()
		if selected_tiles.size() == 2:
			_check_for_match()
	else:
		_clear_selection()
		selected_tiles.append(tile_data)
		tile_node.select_tile()

func _clear_selection():
	for tile_data in selected_tiles:
		if is_instance_valid(tile_data.node): # 이미 제거된 타일이 아닐 경우
			tile_data.node.deselect_tile()
	selected_tiles.clear()

func _check_for_match():
	if selected_tiles.size() == 2:
		var tile1 = selected_tiles[0]
		var tile2 = selected_tiles[1]

		if tile1.id == tile2.id:
			_remove_pair(tile1, tile2)
		else:
			_clear_selection()

func _remove_pair(tile1_data: Dictionary, tile2_data: Dictionary):
	print("Match! Removing tiles.")
	tiles[tile1_data.z][tile1_data.y][tile1_data.x] = -1
	tiles[tile2_data.z][tile2_data.y][tile2_data.x] = -1

	tile1_data.node.remove_tile()
	tile2_data.node.remove_tile()

	active_tiles.erase(tile1_data.node)
	active_tiles.erase(tile2_data.node)

	_clear_selection()
	_check_game_over()

func _can_access_tile(x: int, y: int, z: int) -> bool:
	if z >= board_depth - 1: # 가장 위층 타일은 항상 접근 가능
		return true

	# 2D 층 쌓기에서는 기본적으로 바로 위 타일만 확인합니다.
	if tiles[z + 1][y][x] != -1:
		return false
	return true

func _check_game_over():
	if active_tiles.size() == 0:
		print("Game Over! All tiles removed.")
		# 게임 승리 처리 로직
