extends Node

## Global variables

# Game process
var game_root : Node2D
var game_state : String

## Open game scene function
func change_scene(action: String):
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
	if action == "new_game":
		print("Configuring new game")
		game_state = "GenNew"

	elif action == "load_game":
		print("Configuring saved game")
		game_state = "LoadLast"

func pause():
	get_tree().paused = !get_tree().paused

func game_over():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

