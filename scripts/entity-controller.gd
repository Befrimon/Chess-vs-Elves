extends Node

## Constants
const TILE_SIZE = 80  # Entity size
const ENTITY = preload("res://prefabs/entity.tscn")  # Entity object

# Elf spawning
const ELF_SPEED = 50
const MIN_TICK = 5
const MAX_TICK = 15

# Figures spawning
const ROOK_SPEED = 400
const ROOK_POSITIONS = [310, 390, 470, 550, 630, 710]

const BATTLE_FIG = ["pawn_figure", "knight_figure", "bishop_figure", "queen_figure"]
const costs = {
	"rook_figure": ["Rook", 0],
	"king_figure": ["King", 100],
	"pawn_figure": ["Pawn", 50],
}
var crown_count : int

# Nodes
var controller_group : Node
var elfs_group : Node2D
var figures_group : Node2D


func new_entity(ename: String, pos: Vector2):
	print("Creating new %s" % ename)
	
	if "elf" not in ename and (not check_close(pos) or costs[ename][1] > crown_count):
		return
	elif "elf" not in ename:
		crown_count -= costs[ename][1]
	
	# Create entity
	var entity = ENTITY.duplicate().instantiate()
	var display_name = ename.split("_")[0].capitalize()
	entity.init(display_name, ename, pos)
	
	# Create controller 
	var controller = load("res://scripts/entities/%s.gd" % ename).new(entity)
	entity.set_controller(controller)
	controller_group.add_child(controller)
	
	# Create eat area
	if ename in BATTLE_FIG:
		var eat_area = load("res://prefabs/areas/%s.tscn" % ename).instantiate()
		entity.add_child(eat_area)
		controller.eat_area = eat_area
	
	if "elf" in ename:
		elfs_group.add_child(entity)
	elif "figure" in ename:
		figures_group.add_child(entity)

func get_figure(pos: Vector2):
	for entity in figures_group.get_child_count():
		var figure = figures_group.get_child(entity)
		if figure.position == convert_pos(pos): return figure
	return null

func convert_pos(raw_pos: Vector2):
	var map_pos = Preview.MAP_POS
	var index_pos = Vector2(int((raw_pos.x - map_pos.x) / 80), int((raw_pos.y - map_pos.y) / 80))
	return map_pos + index_pos*80 + Vector2(1, 1)*TILE_SIZE/2

func check_close(pos: Vector2):
	for entity in figures_group.get_child_count():
		var figure = figures_group.get_child(entity)
		if figure.position == pos: return false
	return true


func pregen_rooks():
	for y_pos in ROOK_POSITIONS:
		new_entity("rook_figure", Vector2(220, y_pos))

