extends Node

## Constants
const TILE_SIZE = 80  # Entity size
const ENTITY = preload("res://prefabs/entity.tscn")  # Entity object

# Elf spawning
const ELF_SPEED = 150
const MIN_TICK = 1
const MAX_TICK = 2

# Figures spawning
const ROOK_SPEED = 400
const ROOK_POSITIONS = [310, 390, 470, 550, 630, 710]

const BATTLE_FIG = ["pawn", "knight", "bishop", "queen"]

# Nodes
var controller_group : Node


func new_entity(parent: Node2D, name: String, pos: Vector2):
	print("Creating new %s" % name)
	
	# Create entity
	var entity = ENTITY.duplicate().instantiate()
	entity.init(name, pos)
	
	# Create controller 
	var controller = load("res://scripts/entities/%s.gd" % name).new(entity)
	entity.set_controller(controller)
	controller_group.add_child(controller)
	
	# Create eat area
	if name in BATTLE_FIG:
		var eat_area = load("res://prefabs/areas/pawn.tscn").instantiate()
		entity.add_child(eat_area)
		controller.eat_area = eat_area
	
	parent.add_child(entity)


func pregen_rooks(parent: Node2D):
	for y_pos in ROOK_POSITIONS:
		new_entity(parent, "rook", Vector2(220, y_pos))

