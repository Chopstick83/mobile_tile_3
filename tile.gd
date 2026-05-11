extends Area2D

signal tile_clicked(tile_data)

@export var texture_atlas: Texture2D # 타일 텍스처 아틀라스 (예: 스프라이트 시트)
@export var tile_size: Vector2 = Vector2(64, 64) # 타일 하나의 크기

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var grid_x: int
var grid_y: int
var grid_z: int
var tile_id: int # 타일의 종류 (아틀라스 내의 인덱스 또는 고유 ID)
var is_selected: bool = false
var is_removed: bool = false

func init_tile(x: int, y: int, z: int, id: int):
	grid_x = x
	grid_y = y
	grid_z = z
	tile_id = id

	position = Vector2(grid_x * tile_size.x + 32, grid_y * tile_size.y + 32)
	z_index = grid_z # 높은 층이 더 위에 그려지도록
	
	_update_sprite()

func _update_sprite():
	if texture_atlas:
		var tile_count_in_atlas_x = int(texture_atlas.get_width() / tile_size.x)
		var tile_index_x = tile_id % tile_count_in_atlas_x
		var tile_index_y = tile_id / tile_count_in_atlas_x

		# 이미지 선택 변경
		sprite_2d.region_rect = Rect2(tile_index_x * tile_size.x, tile_index_y * tile_size.y, tile_size.x, tile_size.y)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_removed:
			emit_signal("tile_clicked", {
				"x": grid_x,
				"y": grid_y,
				"z": grid_z,
				"id": tile_id,
				"node": self
			})

func select_tile():
	is_selected = true
	modulate = Color.RED # 타일 전체 색상 변경

func deselect_tile():
	is_selected = false
	modulate = Color.WHITE

func remove_tile():
	is_removed = true
	queue_free()
