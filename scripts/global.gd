extends Node

const TILE_SIZE :Vector2 = Vector2(92, 92)
const MAP_POS :Vector2 = Vector2(460, 530)
const MAP_SIZE :Vector2 = Vector2(20, 6)
const POS_DELTA :Vector2 = Vector2(0, 20)
const ENTITY :PackedScene = preload("res://prefabs/entity.tscn")
const HITBOX :Shape2D = preload("res://prefabs/entity_hitbox.tres")
const MOVE_CELL :PackedScene = preload("res://prefabs/move_cell.tscn")

const MAX_FIGURE = {
	"king_figure": 1,
	"pawn_figure": 6
}
const ENTITY_PARAM = {
	## Elfs params
	"forest_elf": {
		"name": "Forest elf",
		"type": "attacker",
		# Levels for elfs its his waves
		"level1": {"hits": 1., "value": -1., "cooldown": 1}
	},
	
	## Figure params
	"rook_defender": {
		"name": "ROOOOK!",
		"type": "attacker",
		"level1": {"hits": INF, "value": INF, "cooldown": 0}
	},
	"king_figure": {
		"name": "King",
		"type": "support",
		"level1": {"cost": 100, "hits": 1., "value": 25., "cooldown": 10},
		"level2": {"cost": 0, "hits": 1., "value": 50., "cooldown": 10},
		"level3": {"cost": 0, "hits": 2., "value": 50., "cooldown": 8},
		"level4": {"cost": 0, "hits": 2., "value": 75., "cooldown": 8},
		"level5": {"cost": 0, "hits": 3., "value": 100., "cooldown": 6}
	},
	"pawn_figure": {
		"name": "Pawn",
		"type": "attacker",
		"level1": {"cost": 50, "hits": 2., "value": -1., "cooldown": 1},
		"level2": {"cost": 0, "hits": 2., "value": -2., "cooldown": 1},
		"level3": {"cost": 0, "hits": 3., "value": -3., "cooldown": 1},
		"level4": {"cost": 0, "hits": 5., "value": -4., "cooldown": 1},
		"level5": {"cost": 0, "hits": 7., "value": -5., "cooldown": 1}
	}
}

var timer :float = 0
const PREPARE_TIME :int = 10
const SPAWN_TIME :Array[int] = [5, 20]
const ELF_XCOORD :int = 2000
var busy_cells :Array[Vector2] = []

func position_normilize(pos :Vector2):
	var res = Vector2i((pos - MAP_POS + TILE_SIZE/2) / TILE_SIZE)
	return MAP_POS + Vector2(res) * TILE_SIZE
