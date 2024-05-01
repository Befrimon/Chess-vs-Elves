extends Node2D

enum Action {OPEN_GAME = 0, OPTIONS = 1, SHOP = 2, STATS = 3, HELP = 4, QUIT = 5,
			NEW_GAME = 6, LOAD_GAME = 7, DELETE_SAVE = 8,
			CONFIRM_ACCEPT = -1, CONFIRM_DENY = -2, OPEN_MENU = -3}

var map_size :Vector2i
var tile_map :TileMap
var chess_tiles :Dictionary = {}
var chess_delay :float = 0

var shading :ColorRect
var confirm_window :Window
var accept_action :Callable

func _ready() -> void:
	get_tree().paused = false
	shading = get_node('Shading')
	confirm_window = get_node("ConfirmDialog")
	
	## Configure tile map
	tile_map = get_node("TileMap")
	tile_map.scale = Vector2(1, 1) * Global.config["game_map"]["tile"]\
					/ Vector2(tile_map.tile_set.tile_size)
	
	map_size = Vector2i(get_viewport_rect().size / Global.config["game_map"]["tile"])
	for x in range(map_size.x+1):
		for y in range(map_size.y+1):
			tile_map.set_cell(0, Vector2i(x, y), 2, Vector2i.ZERO)
	
	## Configure buttons
	for btn in get_node("MainMenu/MainButtons").get_children()\
			 + get_node("MainMenu/SmallButtons").get_children()\
			 + get_node("ConfirmDialog/Buttons").get_children()\
			 + [get_node("SavesMenu/BackBtn")]:
		btn.pressed.connect(_on_btn_pressed.bind(btn.get_meta("click_action")))
		btn.button_down.connect(_on_btn_down.bind(btn.get_path()))
		btn.button_up.connect(_on_btn_up.bind(btn.get_path()))
	
	## Load save files
	var saves :PackedStringArray = DirAccess.get_files_at("user://saves")
	saves.reverse()
	for save in saves:
		var data = JSON.parse_string(FileAccess.get_file_as_string("user://saves/%s" % save))
		var save_item = load("res://prefabs/save_item.tscn").instantiate()
		save_item.get_node("InfoLabels/Title").text = data["name"]
		save_item.get_node("InfoLabels/WaveInfo").text = "%s секунд - %s волна" % [int(data["timer"]), data["wave"]]
		save_item.get_node("InfoLabels/CrownInfo").text = "%s корон" % data["crown_count"]
		# save_item.get_node("InfoLabels/SpellInfo").text = "%s заклинаний" % data[]
		save_item.get_node("Buttons/ResumeButton").pressed.connect(load_game.bind(save))
		save_item.get_node("Buttons/DeleteButton").pressed.connect(delete_save.bind(save_item, save))
		get_node("SavesMenu/SavesContainer/VerticalContainer").add_child(save_item)
	var new_game_btn :TextureButton = TextureButton.new()
	new_game_btn.texture_normal = load("res://textures/GUI/new_game.png")
	new_game_btn.pressed.connect(new_game)
	get_node("SavesMenu/SavesContainer/VerticalContainer").add_child(new_game_btn)

var timer :float = 0
func _process(delta :float) -> void:
	timer += delta
	
	## Background tiles animation
	if timer > chess_delay:
		chess_delay += .5
		var x :int = randi_range(0, map_size.x)
		var y :int = randi_range(0, map_size.y)
		
		tile_map.set_cell(1, Vector2i(x, y), (x+y)%2, Vector2i.ZERO)
		chess_tiles[Vector2i(x, y)] = timer + randi_range(1, 5)
	
	for tile in chess_tiles:
		if timer > chess_tiles[tile]:
			tile_map.erase_cell(1, tile)
			chess_tiles.erase(tile)

func _on_btn_pressed(action :Action) -> void:
	match action:
		## Button actions
		Action.OPEN_GAME:
			get_node("MainMenu").visible = false
			get_node("SavesMenu").visible = true
		Action.OPTIONS: pass
		Action.HELP: add_child(load("res://prefabs/helpbook.tscn").instantiate())
		Action.QUIT:
			confirm_window.get_node("Title/Label").text = "Выйти из игры?"
			shading.visible = true
			confirm_window.visible = true
			accept_action = Callable(get_tree(), "quit")
		
		Action.OPEN_MENU:
			for item in get_children():
				if "Menu" in item.name:
					item.visible = false
			get_node("MainMenu").visible = true
		
		# Confirm buttons
		Action.CONFIRM_ACCEPT: accept_action.call()
		Action.CONFIRM_DENY:
			shading.visible = false
			confirm_window.visible = false

func new_game() -> void:
	Global.status = Global.GameState.NEW
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func load_game(path :String) -> void:
	Global.status = Global.GameState.LOAD
	Global.load_path = path
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func delete_save(item :TextureRect, path :String) -> void:
	DirAccess.remove_absolute("user://saves/%s" % path)
	get_node("SavesMenu/SavesContainer/VerticalContainer").remove_child(item)

## Move button text/icon on click
func _on_btn_down(btn_name :String) -> void:
	get_node(btn_name).get_child(0).position.y += 8

func _on_btn_up(btn_name :String) -> void:
	get_node(btn_name).get_child(0).position.y -= 8
