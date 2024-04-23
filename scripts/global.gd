extends Node

enum GameState {INACTIVE, NEW, LOAD, PROCESS, PAUSE, PREVIEW}

var config :Dictionary
var map_rect :Rect2

var status :GameState = GameState.INACTIVE

func _ready() -> void:
	# Read config file
	config = JSON.parse_string(FileAccess.get_file_as_string("res://sources/config.json"))
	map_rect = Rect2(str_to_var(config["game_map"]["position"])*config["game_map"]["tile"],
					 str_to_var(config["game_map"]["size"])*config["game_map"]["tile"])
	
func position_normilize(pos :Vector2) -> Vector2:
	return Vector2(Vector2i(pos / config["game_map"]["tile"])) + Vector2(.5, .3)
