extends Node

enum GameState {INACTIVE, NEW, LOAD, PROCESS, PAUSE, PREVIEW}

var config :Dictionary
var userdata :Dictionary
var map_rect :Rect2

var status :GameState = GameState.INACTIVE
var load_path :String = "none"

func _ready() -> void:
	# Read in-game config file
	config = JSON.parse_string(FileAccess.get_file_as_string("res://sources/config.json"))
	map_rect = Rect2(str_to_var(config["game_map"]["position"])*config["game_map"]["tile"],
					 str_to_var(config["game_map"]["size"])*config["game_map"]["tile"])
	
	# Check saves directory
	if !DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_absolute("user://saves")
	
	# Check user config file
	var file :FileAccess = FileAccess.open("user://data.json", FileAccess.WRITE_READ)
	if file.get_line() == "":
		userdata = JSON.parse_string(FileAccess.get_file_as_string("res://sources/udata_example.json"))
		file.store_string(JSON.stringify(userdata))
	else:
		userdata = JSON.parse_string(FileAccess.get_file_as_string("user://data.json"))
	file.close()

func _notification(what :int) -> void:
	# Hadle close event and save game
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var file = FileAccess.open("user://data.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(userdata))
		file.close()
		
		get_tree().quit(0)

func position_normilize(pos :Vector2) -> Vector2:
	return Vector2(Vector2i(pos / config["game_map"]["tile"])) + Vector2(.5, .3)
