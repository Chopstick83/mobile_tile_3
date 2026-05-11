extends Node2D

@onready var grid_container: GridContainer = $GridContainer

@export var puzzle_texture : Texture2D # 퍼즐 조각으로 사용할 이미지를 여기에 드래그 앤 드롭
@export var grid_size_x : int = 8
@export var grid_size_y : int = 12

const button_width: int = 32
const button_height: int = 32

func _ready():
	for y in range(grid_size_y):
		for x in range(grid_size_x):
			var button = TextureButton.new()
			button.texture_normal = puzzle_texture
			button.texture_pressed = puzzle_texture # 클릭 시 변화를 원하면 다른 텍스처 사용 가능
			button.custom_minimum_size = Vector2(button_width, button_height) # 버튼 크기 조절 (원하는 크기로 변경)

			button.set_stretch_mode(TextureButton.STRETCH_KEEP_ASPECT_CENTERED)

			button.pressed.connect(on_puzzle_button_pressed.bind(x, y))
			grid_container.add_child(button)

	# GridContainer 가로 중앙 정렬 및 상단 위치
	var viewport_size = get_viewport_rect().size
	var grid_container_size = grid_container.get_combined_minimum_size()
	
	# 상단에 위치시키기 위해 Y 포지션을 0에 가깝게 설정
	grid_container.position.y = 20 # 원하는 상단 여백
	grid_container.position.x = (viewport_size.x - grid_container_size.x) / 2

func on_puzzle_button_pressed(x : int, y : int):
	print("퍼즐 조각 클릭됨: ", x, ", ", y)
	# 여기에 퍼즐 로직을 추가합니다 (예: 조각 바꾸기, 상태 변경 등)
