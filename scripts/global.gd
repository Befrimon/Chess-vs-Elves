extends Node

const TILE_SIZE :Vector2 = Vector2(92, 92)
const MAP_POS :Vector2 = Vector2(460, 530)
const MAP_SIZE :Vector2 = Vector2(20, 6)
const MAP_RECT :Rect2 = Rect2(MAP_POS-TILE_SIZE/2, MAP_SIZE*TILE_SIZE)
const POS_DELTA :Vector2 = Vector2(0, 20)
const ENTITY :PackedScene = preload("res://prefabs/entity.tscn")
const HITBOX :Shape2D = preload("res://prefabs/entity_hitbox.tres")
const MOVE_CELL :PackedScene = preload("res://prefabs/move_cell.tscn")

const MAX_FIGURE :Dictionary = {
	"king_figure": 1,
	"pawn_figure": 6,
	"bishop_figure": 2,
	"knight_figure": 2,
	"queen_figure": 1
}
const LEVEL_EXP :Array[float] = [0, 100, 600, 1600, 3100]
var ENTITY_PARAM :Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://sources/entity_info.json"))

var timer :float = 0
const WAVES :Array[Dictionary] = [
	# epe - elves spawn count per spawn event
	{"name": "Приготовься", "epe": 0, "elf_spawn": [1, 1], "duration": 10},
	{"name": "1 волна", "epe": 1, "elf_spawn": [5, 15], "duration": 120},
	{"name": "2 волна", "epe": 2, "elf_spawn": [5, 15], "duration": 60},
	{"name": "3 волна", "epe": 2, "elf_spawn": [5, 10], "duration": 60},
	{"name": "4 волна", "epe": 2, "elf_spawn": [5, 15], "duration": 120},
	{"name": "Удачи!", "epe": 3, "elf_spawn": [5, 15], "duration": INF}
]
const ELF_CHANCE :Array[Dictionary] = [
	{"forest_elf": 0., "dark_elf": 0.},  # Prepare wave
	{"forest_elf": 1., "dark_elf": 0.},  # 1 wave
	{"forest_elf": 1., "dark_elf": 0.},  # 2 wave
	{"forest_elf": 1., "dark_elf": 0.},  # 3 wave
	{"forest_elf": .8, "dark_elf": .2},  # 4 wave
	{"forest_elf": .5, "dark_elf": .5},  # Infinity wave
]
const ELF_XCOORD :int = 2000
var busy_cells :Array[Vector2] = []

func position_normilize(pos :Vector2) -> Vector2:
	var res = Vector2i((pos - MAP_POS + TILE_SIZE/2) / TILE_SIZE)
	return MAP_POS + Vector2(res) * TILE_SIZE
