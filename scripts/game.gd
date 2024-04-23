class_name Game extends Node2D

## Declare variables
# Child nodes
var tile_map :TileMap = TileMap.new()  # Replace later on texture (BackgroundMap node)
var preview_map :TileMap = TileMap.new()
var entities :Node2D
var helpbook :Node2D

var busy_cells :Array[Vector2] = []
var entity_count :int = 0
var cur_wave :int = 0
var crown_count :int = 0

var timer :float = 0
var spawn :float = 0
var wave_duration :float = 0

var entity_ids :Array = [Rook, Pawn, King, Bishop, Knight, Queen, Elf]
var total_entities :Dictionary = {
	Entity.Name.ROOK: 0,
	Entity.Name.PAWN: 0,
	Entity.Name.KING: 0,
	Entity.Name.BISHOP: 0,
	Entity.Name.KNIGHT: 0,
	Entity.Name.QUEEN: 0,
}
var selected_entity :Entity
var cur_preview :int = 0

var upgrade_btn :TextureButton
var sell_btn :TextureButton
var rest_btn :TextureButton

var help_btn :TextureButton

func _ready() -> void:
	## Get child nodes
	entities = get_node("Entities")
	helpbook = get_node("Helpbook")
	
	## Configure tile map
	tile_map.tile_set = load("res://sources/map_tiles.tres")
	tile_map.scale = Vector2(1, 1) * Global.config["game_map"]["tile"]\
					/ Vector2(tile_map.tile_set.tile_size)
	add_child(tile_map)
	
	preview_map.tile_set = load("res://sources/preview.tres")
	preview_map.scale = Vector2(1, 1) * Global.config["game_map"]["tile"]\
					/ Vector2(preview_map.tile_set.tile_size)
	preview_map.position.y += -.3*Global.config["game_map"]["tile"]
	add_child(preview_map)
	
	## Generate map
	var map_size :Vector2i = Vector2i(get_viewport_rect().size / Global.config["game_map"]["tile"])
	for x in range(map_size.x+1):
		for y in range(map_size.y+1):
			if Global.map_rect.has_point(Vector2(x, y)*Global.config["game_map"]["tile"]):
				tile_map.set_cell(0, Vector2i(x, y), (x+y)%2, Vector2i.ZERO)
				
				var cell :AnimatedSprite2D = AnimatedSprite2D.new()
				cell.name = var_to_str(Vector2i(x, y))
				cell.sprite_frames = load("res://animations/move_cell.tres")
				cell.scale =  Vector2(1, 1) * Global.config["game_map"]["tile"]\
								/ cell.sprite_frames.get_frame_texture("default", 0).get_size()
				cell.play("default")
				cell.visible = false
				cell.position = Vector2(x+.5, y+.5) * Global.config["game_map"]["tile"]
				get_node("MoveCells").add_child(cell)
			else:
				tile_map.set_cell(0, Vector2i(x, y), 2, Vector2i.ZERO)
	
	## Configure entity buttons
	upgrade_btn = get_node("GUI/EntityButtons/UpgradeButton")
	sell_btn = get_node("GUI/EntityButtons/SellButton")
	rest_btn = get_node("GUI/EntityButtons/RestButton")
	help_btn = get_node("GUI/SmallButtons/HelpBtn")
	
	upgrade_btn.button_down.connect(upgrade_active)
	sell_btn.button_down.connect(sell_active)
	rest_btn.button_down.connect(rest_active)
	help_btn.button_down.connect(open_help)
	
	## Configure game
	match Global.status:
		Global.GameState.NEW: new_game()
		Global.GameState.LOAD: load_game()
	Global.status = Global.GameState.PROCESS

func save_game() -> void:
	# Create dictionary
	var data :Dictionary = {
		"wave": cur_wave,
		"timer": timer,
		"wave_duration": wave_duration,
		"spawn": spawn,
		"crown_count": crown_count,
		"entity_count": entity_count,
		"entities": {}
	}
	
	# Save entities
	for entity in get_node("Entities").get_children():
		data["entities"][entity.name] = {
			"iname": entity.iname,
			"position": var_to_str(entity.position),
			"level": entity.level,
			"exp": entity.exp,
			"damage": entity.damage,
			"cooldown": entity.skill_cooldown
		}
	
	# Save data
	FileAccess.open("user://save.json", FileAccess.WRITE).store_string(JSON.stringify(data, "\t"))

func new_game() -> void:
	crown_count = Global.config["start_crown_count"]
	wave_duration = Global.config["waves"]["wave0"]["duration"]
	
	## Spawn rooks
	for y in range(str_to_var(Global.config["game_map"]["size"]).y):
		var tile = Global.config["game_map"]["tile"]
		var new_pos :Vector2 = (str_to_var(Global.config["game_map"]["position"]) + Vector2(-1, y))*tile
		get_node("Entities").add_child(Rook.new(new_pos, entity_count))
		entity_count += 1
	save_game()

func load_game() -> void:
	var save = JSON.parse_string(FileAccess.get_file_as_string("user://save.json"))
	
	# load variables
	cur_wave = save["wave"]
	timer = save["timer"]
	spawn = save["spawn"]
	wave_duration = save["wave_duration"]
	crown_count = save["crown_count"]
	entity_count = save["entity_count"]
	
	# load entity
	for entity in save["entities"]:
		var data :Dictionary = save["entities"][entity]
		var new_entity = entity_ids[data["iname"]]\
				.new(str_to_var(data["position"]), int(entity.split("-")[1]))
		new_entity.level = data["level"]
		new_entity.exp = data["exp"]
		new_entity.damage = data["damage"]
		new_entity.skill_cooldown = data["cooldown"]
		busy_cells.append(Global.position_normilize(position))
		get_node("Entities").add_child(new_entity)

func _process(delta :float) -> void:
	timer += delta  # Update timer
	wave_duration -= delta
	draw_move()
	
	## Give crowns every 10 seconds
	if int(timer+delta)%10 == 0 and int(timer)%10 == 9:
		crown_count += Global.config["waves"]["wave%s"%cur_wave]["crown_per10"]
	
	## Update game info
	get_node("GUI/GameInfo/TimerLabel").text = "%s: %s сек"\
		% [Global.config["waves"]["wave%s" % cur_wave]["name"], abs(int(wave_duration))]
	get_node("GUI/GameInfo/CrownLabel").text = "Короны: %s" % crown_count
	
	## Update entity info
	get_node("GUI/EntityInfo/Label").text = selected_entity.get_info() if selected_entity != null else ""
	if selected_entity == null or selected_entity.type == Entity.Type.ELF:
		for btn in get_node("GUI/EntityButtons").get_children(): 
			# Disable all if selected elf
			btn.disabled = true
	else:
		# Disable buttons for selected figure
		for btn in get_node("GUI/EntityButtons").get_children(): 
			if btn.get_meta("action") not in selected_entity.disabled_actions:
				btn.disabled = false
			else:
				btn.disabled = true
		
		if !upgrade_btn.disabled and crown_count < selected_entity.data["level%s"%(selected_entity.level+1)]["cost"]:
			# Disable upgrade if crowns is not enough
			upgrade_btn.disabled = true
		
		# Toggle rest button text
		if selected_entity.rest_active:
			rest_btn.get_child(0).text = "Разбудить"
		else:
			rest_btn.get_child(0).text = "Усыпить"
	
	## Disable spawn button if crowns is not enough for btn figure
	for btn in get_node("GUI/SpawnButtons").get_children():
		if crown_count < btn.get_meta("crown") or total_entities[btn.get_meta("eid")] == btn.get_meta("max"):
			btn.disabled = true
		else:
			btn.disabled = false
	
	## Update waves
	if int(wave_duration) == 0:
		cur_wave += 1
		wave_duration = Global.config["waves"]["wave%s" % cur_wave]["duration"]
		spawn = timer  # Spawn new elves now!
	
	## Spawn elves
	if spawn <= timer:
		for i in range(Global.config["waves"]["wave%s" % cur_wave]["elves_at_time"]):
			var new_pos :Vector2 = Vector2(Global.config["elf_start_x"],
						Global.config["game_map"]["tile"] * \
						(str_to_var(Global.config["game_map"]["position"]).y + randi_range(0, 5)))
			get_node("Entities").add_child(Elf.new(new_pos, entity_count, get_elf()))
			
			# Set config data about new elf
			busy_cells.append(Global.position_normilize(new_pos))
			entity_count += 1
		spawn += randi_range(
			Global.config["waves"]["wave%s" % cur_wave]["spawn_delay"][0],
			Global.config["waves"]["wave%s" % cur_wave]["spawn_delay"][1]
		)

func _input(event :InputEvent) -> void:
	## Draw preview figure
	if event is InputEventMouseMotion and Global.status == Global.GameState.PREVIEW:
		preview_map.clear()
		if Global.map_rect.has_point(event.position):
			preview_map.set_cell(0, Global.position_normilize(event.position), cur_preview, Vector2.ZERO)
	
	## Create new figure
	if event is InputEventMouseButton and event.button_index == 1 and Global.status == Global.GameState.PREVIEW:
		for btn in get_node("GUI/SpawnButtons").get_children():
			btn.button_pressed = false  # Unpress spawn button
		if Global.map_rect.has_point(event.position):
			var new_pos :Vector2 = Global.position_normilize(event.position) * Global.config["game_map"]["tile"]
			var new_fig :Entity = entity_ids[cur_preview].new(new_pos, entity_count)
			get_node("Entities").add_child(new_fig)
			
			# Set config data about new figure
			crown_count -= new_fig.data["level1"]["cost"]
			busy_cells.append(Global.position_normilize(new_pos))
			total_entities[new_fig.iname] += 1
			entity_count += 1
	
	## Handle move action
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		for cell in get_node("MoveCells").get_children():
			if cell.visible and Rect2(cell.position - Vector2(.5, .5)*Global.config["game_map"]["tile"],
					Vector2(1, 1)*Global.config["game_map"]["tile"]).has_point(event.position):
				busy_cells.remove_at(busy_cells.find(Global.position_normilize(selected_entity.position)))
				selected_entity.target = (Vector2(str_to_var(cell.name))+Vector2(.5, .3))*Global.config["game_map"]["tile"]
				selected_entity.hitbox.disabled = true
	
	## Select new active entity
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed and\
			Global.map_rect.expand(Vector2(-1, 0)*Global.config["game_map"]["tile"]).has_point(event.position):
		if selected_entity != null:
			# Disable selection for previous
			selected_entity.highlighting.visible = false
		var find :bool = false
		for entity in get_node("Entities").get_children():
			if Rect2(entity.position - Vector2(1, 1)*Global.config["game_map"]["tile"]/2, 
					 Vector2(1, 1)*Global.config["game_map"]["tile"]).has_point(event.position):
				if selected_entity == entity:
					break
				# Set new selection
				selected_entity = entity
				selected_entity.highlighting.visible = true
				find = true
				break
		if !find:
			selected_entity = null

## Draw move cells for selected figure
func draw_move() -> void:
	for cell in get_node("MoveCells").get_children():
		cell.visible = false  # Disable all
	
	if selected_entity == null or selected_entity.rest_active:
		return  # If no selected figure or selected rest now
	
	for direction in selected_entity.data["move"]:
		for i in range(1, selected_entity.data["move"][direction]+1):
			var cell_pos = Global.position_normilize(selected_entity.position) + i*str_to_var(direction)
			if cell_pos in busy_cells or !Global.map_rect.has_point(cell_pos*Global.config["game_map"]["tile"]):
				break  # Stop if on line figure or map edge
			get_node("MoveCells/%s" % var_to_str(Vector2i(cell_pos))).visible = true

func _notification(what :int) -> void:
	# Hadle close event and save game
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()

## UI functions
# Upgrade active figure
func upgrade_active() -> void:
	upgrade_btn.get_child(0).position.y -= 8
	selected_entity.level += 1
	selected_entity.damage = 0
	crown_count -= selected_entity.data["level%s"%selected_entity.level]["cost"]
	selected_entity.disabled_actions.append(Entity.Actions.UPGRADE)

# Sell active figure
func sell_active() -> void:
	# sell_btn.get_child(0).position.y -= 8
	crown_count += selected_entity.data["level%s"%selected_entity.level]["cost"]/2
	selected_entity.kill()

# Send to rest active figure
func rest_active() -> void:
	selected_entity.rest_active = !selected_entity.rest_active
	if selected_entity.rest_active:
		selected_entity.texture.play("rest")
	else:
		selected_entity.texture.play("idle")

# Toggle preview mode
func toggle_preview(toggled_on :bool, entity_name :int) -> void:
	if selected_entity != null:
		# Disable selection
		selected_entity.highlighting.visible = false
		selected_entity = null
	
	if toggled_on:
		Global.status = Global.GameState.PREVIEW
		cur_preview = entity_name  # Figure that draw on preview
	else:
		Global.status = Global.GameState.PROCESS
		preview_map.clear()  # Clear preview

# Open helpbook
func open_help():
	help_btn.get_child(0).position.y -= 8
	get_tree().paused = true
	helpbook.visible = true

## Get random elf ID
func get_elf() -> int:
	var elf_type = randf()
	for type in range(len(Global.config["waves"]["wave%s" % cur_wave]["spawn_chance"])):
		if elf_type < Global.config["waves"]["wave%s" % cur_wave]["spawn_chance"][type]:
			return Entity.Name.FOREST_ELF + type
		elf_type -= Global.config["waves"]["wave%s" % cur_wave]["spawn_chance"][type]
	return Entity.Name.FOREST_ELF  # Forest elf if error occurred

