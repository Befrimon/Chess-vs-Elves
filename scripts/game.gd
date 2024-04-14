extends Node2D
class_name Game

## Declare variables
var chess_group :Node2D
var elf_group :Node2D
var other_group :Node2D
var map_group :TileMap
var interface :Control

var entity_count :int
var crown_count :int

var preview_figure :Preview
var preview_enable :bool
var move_enable :bool
var active :Entity

const CROWN_COOLDOWN :int = 10  # In seconds

func _ready():
	## Assign variables
	chess_group = get_node("ChessEntities")
	elf_group = get_node("ElfEntities")
	other_group = get_node("OtherEntities")
	map_group = get_node("TileMap")
	interface = get_node("UserInterface")
	
	entity_count = 0
	crown_count = 125
	
	preview_figure = load("res://scripts/preview_figure.gd").new()
	preview_enable = false
	add_child(preview_figure)
	
	## Configure childs
	map_group.position = Global.MAP_POS - Global.TILE_SIZE / 2 + Global.POS_DELTA
	map_group.scale = Global.TILE_SIZE / Vector2(map_group.tile_set.tile_size)
	interface.parent = self
	
	## Generate map
	for x in range(Global.MAP_SIZE.x):
		for y in range(Global.MAP_SIZE.y):
			map_group.set_cell(0, Vector2i(x, y), (x+y)%2, Vector2i.ZERO)
	
	## Generate rooks
	for y in range(Global.MAP_SIZE.y):
		create_entity("rook_defender", Vector2(Global.MAP_POS + Vector2(-1, y)*Global.TILE_SIZE))


var next_event :int = Global.PREPARE_TIME
func _process(delta):
	if int(Global.timer+delta) % CROWN_COOLDOWN == 0 and int(Global.timer) % CROWN_COOLDOWN == 9:
		crown_count += 25
	
	if !get_tree().paused:
		Global.timer += delta

	if Global.timer >= next_event:
		print("[INFO] New event now!")
		create_entity(
			"forest_elf", 
			Vector2(Global.ELF_XCOORD, Global.MAP_POS.y + Global.TILE_SIZE.y*randi_range(0, 5))
		)
		next_event += randi_range(Global.SPAWN_TIME[0], Global.SPAWN_TIME[1])
	
	# Find active entity
	var flag :bool = false
	for entity in chess_group.get_children() + elf_group.get_children() + other_group.get_children():
		if entity.name == "Active":
			active = entity
			flag = true
			break
	interface.update_figure_info(active if flag else null)

func _input(event):
	if preview_enable and event is InputEventMouseMotion:
		var move_pos = Global.position_normilize(event.position)
		preview_figure.visible = Global.MAP_RECT.has_point(event.position) and move_pos not in Global.busy_cells
		preview_figure.set_new(move_pos)
	
	if event is InputEventMouseButton and event.button_index == 1 and preview_enable:
		var click_pos = Global.position_normilize(event.position)
		preview_figure.visible = false
		preview_enable = false
		if Global.MAP_RECT.has_point(event.position) and click_pos not in Global.busy_cells:
			interface.get_node("SpawnButtons/%s" % preview_figure.figure).button_pressed = false
			create_entity(preview_figure.figure, click_pos)


func create_entity(eid :String, pos :Vector2 = Vector2.ZERO):
	print("[INFO] Creating new entity (%s) at %s" % [eid, pos])
	var cost = 0
	
	if "figure" in eid:
		cost = Global.ENTITY_PARAM[eid]["level1"]["cost"]
		if cost > crown_count:
			print("[INFO] Not enough crowns for %s" % eid)
			return
	if "figure" in eid and len(get_tree().get_nodes_in_group(eid)) >= Global.MAX_FIGURE[eid]:
		print("[INFO] Too many %s in game" % eid)
		return
	
	crown_count -= cost
	var entity = Global.ENTITY.duplicate().instantiate()  # Create new entity object
	entity.init("Entity-%s (%s)" % [str(entity_count), eid], eid, pos)  # Init object
	entity_count += 1  # Update entity counter
	
	# Add entity by type
	match entity.type:
		"figure": chess_group.add_child(entity)
		"elf": elf_group.add_child(entity)
		_: other_group.add_child(entity)

