extends Node2D

enum Action {NEW_GAME = 0, LOAD_GAME = 1, OPTIONS = 2, HELP = 3, QUIT = 4, CLOSE_CONFIRM = 5, 
	CLOSE_REJECT = 6, DELETE_CONFIRM = 7, DELTE_REJECT = 8}

var map_size :Vector2i
var tile_map :TileMap = TileMap.new()
var chess_tiles :Dictionary = {}
var chess_delay :float = 0

var close_window :TextureRect
var close_move :String = "false"
var close_target :Vector2

var delete_window :TextureRect
var delete_move :String = "false"
var delete_target :Vector2

func _ready() -> void:
	close_window = get_node("CloseConfirm/ConfirmWindow")
	delete_window = get_node("DeleteConfirm/ConfirmWindow")
	
	## Create tile map
	tile_map.tile_set = load("res://sources/map_tiles.tres")
	tile_map.scale = Vector2(1, 1) * Global.config["game_map"]["tile"]\
					/ Vector2(tile_map.tile_set.tile_size)
	tile_map.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tile_map.z_index = -1
	tile_map.add_layer(1)
	add_child(tile_map)
	
	map_size = Vector2i(get_viewport_rect().size / Global.config["game_map"]["tile"])
	for x in range(map_size.x+1):
		for y in range(map_size.y+1):
			tile_map.set_cell(0, Vector2i(x, y), 2, Vector2i.ZERO)
	
	## Configure buttons
	for btn in get_node("GUI/MainButtons").get_children()\
			 + get_node("GUI/SmallButtons").get_children()\
			 + get_node("CloseConfirm/ConfirmWindow/Buttons").get_children()\
			 + get_node("DeleteConfirm/ConfirmWindow/Buttons").get_children():
		btn.pressed.connect(_on_btn_pressed.bind(btn.get_meta("click_action")))
	
	if !FileAccess.file_exists("user://save.json"):
		get_node("GUI/MainButtons/LoadGameBtn").disabled = true

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
	
	## GUI animations
	if close_move == "open" and close_window.position != close_target:
		close_window.position.y -= 50
	elif close_move == "hide" and close_window.position != close_target:
		close_window.position.y += 50
	elif close_move == "hide":
		get_node("CloseConfirm").visible = false
	
	if delete_move == "open" and delete_window.position != delete_target:
		delete_window.position.y -= 50
	elif delete_move == "hide" and delete_window.position != delete_target:
		delete_window.position.y += 50
	elif delete_move == "hide":
		get_node("DeleteConfirm").visible = false

func _on_btn_pressed(action :Action) -> void:
	match action:
		# Main buttons
		Action.NEW_GAME: new_game()
		Action.LOAD_GAME:
			Global.status = Global.GameState.LOAD
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		Action.OPTIONS: pass
		Action.HELP: pass
		Action.QUIT: open_close_confirm()
		
		# Confirm buttons
		Action.CLOSE_CONFIRM: hide_close_confirm()
		Action.CLOSE_REJECT: get_tree().quit(0)
		
		Action.DELETE_CONFIRM: hide_delete_confirm()
		Action.DELTE_REJECT: 
			Global.status = Global.GameState.NEW
			get_tree().change_scene_to_file("res://scenes/game.tscn")

func new_game() -> void:
	if FileAccess.file_exists("user://save.json"):
		open_delete_confirm()
		return
	Global.status = Global.GameState.NEW
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func open_delete_confirm() -> void:
	delete_window.position.y = 1100
	delete_target = Vector2(610, 300)
	delete_move = "open"
	get_node("DeleteConfirm").visible = true

func hide_delete_confirm() -> void:
	delete_target = Vector2(610, 1100)
	delete_move = "hide"

func open_close_confirm() -> void:
	close_window.position.y = 1100
	close_target = Vector2(610, 300)
	close_move = "open"
	get_node("CloseConfirm").visible = true

func hide_close_confirm() -> void:
	close_target = Vector2(610, 1100)
	close_move = "hide"

## Move button text/icon on click
func _on_btn_down(btn_name :String) -> void:
	get_node("GUI/"+btn_name).get_child(0).position.y += 8

func _on_btn_up(btn_name :String) -> void:
	get_node("GUI/"+btn_name).get_child(0).position.y -= 8
