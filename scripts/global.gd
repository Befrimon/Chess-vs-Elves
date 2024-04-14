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
	"knight_figure": 2
}
const LEVEL_EXP :Array[int] = [0, 100, 600, 1600, 3100]
const ENTITY_PARAM :Dictionary = {
	## Elfs params
	"forest_elf": {
		"name": "Forest elf",
		"type": "attacker",
		"exp_value": 25,
		# Levels for elfs its his waves
		"level1": {"hits": 1., "value": -1., "cooldown": 1}
	},
	"dark_elf": {
		"name": "Dark elf",
		"type": "attacker",
		"exp_value": 50,
		"level1": {"hits": 3., "value": -2., "cooldown": 1}
	},
	
	## Figure params
	"rook_defender": {
		"name": "ROOOOK!",
		"type": "attacker",
		"level1": {"hits": INF, "value": INF, "cooldown": 0}
		# Rook defender has no levels
	},
	"pawn_figure": {
		"name": "Pawn",
		"type": "attacker",
		"level1": {"cost": 50, "hits": 2., "value": -1., "cooldown": 1},
		"level2": {"cost": 150, "hits": 2., "value": -2., "cooldown": 1},
		"level3": {"cost": 300, "hits": 3., "value": -3., "cooldown": 1},
		"level4": {"cost": 500, "hits": 5., "value": -4., "cooldown": 1},
		"level5": {"cost": 800, "hits": 7., "value": -5., "cooldown": 1}
	},
	"king_figure": {
		"name": "King",
		"type": "support",
		"level1": {"cost": 100, "hits": 1., "value": 25, "cooldown": 10},
		"level2": {"cost": 200, "hits": 1., "value": 50, "cooldown": 10},
		"level3": {"cost": 350, "hits": 2., "value": 50, "cooldown": 8},
		"level4": {"cost": 600, "hits": 2., "value": 75, "cooldown": 8},
		"level5": {"cost": 850, "hits": 3., "value": 100, "cooldown": 6}
	},
	"bishop_figure": {
		"name": "Bishop",
		"type": "healer",
		"level1": {"cost": 200, "hits": 1., "value": 1., "cooldown": 5},
		"level2": {"cost": 300, "hits": 1., "value": 2., "cooldown": 5},
		"level3": {"cost": 500, "hits": 1., "value": 2., "cooldown": 3},
		"level4": {"cost": 800, "hits": 2., "value": 3., "cooldown": 3},
		"level5": {"cost": 1000, "hits": 2., "value": 5., "cooldown": 3},
	},
	"knight_figure": {
		"name": "Knight",
		"type": "attacker",
		"level1": {"cost": 300, "hits": 3., "value": -2., "cooldown": 1},
		"level2": {"cost": 500, "hits": 4., "value": -3., "cooldown": 1},
		"level3": {"cost": 800, "hits": 6., "value": -4., "cooldown": 1},
		"level4": {"cost": 1100, "hits": 7., "value": -6., "cooldown": 1},
		"level5": {"cost": 1500, "hits": 9., "value": -8., "cooldown": 1},
	}
}

var timer :float = 0
const WAVES :Array[Dictionary] = [
	# epe - elfs spawn count per spawn event
	{"epe": 0, "elf_spawn": [1, 1], "duration": 10},    # Prepare time
	{"epe": 1, "elf_spawn": [5, 15], "duration": 120},  # 1 wave
	{"epe": 2, "elf_spawn": [5, 15], "duration": 60},   # 2 wave
	{"epe": 2, "elf_spawn": [5, 10], "duration": 60},   # 3 wave
	{"epe": 2, "elf_spawn": [5, 15], "duration": 120},  # 4 wave
	{"epe": 3, "elf_spawn": [5, 15], "duration": INF}   # Infinity wave
]
const ELF_CHANCE :Array[Dictionary] = [
	{"forest_elf": 0., "dark_elf": 0.},  # Prepare wave
	{"forest_elf": 1., "dark_elf": 0.},  # 1 wave
	{"forest_elf": 1., "dark_elf": 0.},  # 2 wave
	{"forest_elf": 1., "dark_elf": 0.},  # 3 wave
	{"forest_elf": .8, "dark_elf": .2},  # 4 wave
	{"forest_elf": .6, "dark_elf": .4},  # Infinity wave
]
const ELF_XCOORD :int = 2000
var busy_cells :Array[Vector2] = []

func position_normilize(pos :Vector2) -> Vector2:
	var res = Vector2i((pos - MAP_POS + TILE_SIZE/2) / TILE_SIZE)
	return MAP_POS + Vector2(res) * TILE_SIZE
