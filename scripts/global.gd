extends Node

## Global variables
var game_state = "None"


## Open game scene function
func change_scene(action: String):
	match action:
		"new_game":
			print("Configuring new game")
			game_state = "New"

		"load_game":
			print("Configuring saved game")
			game_state = "Load"

	get_tree().change_scene_to_file("res://scenes/game.tscn")
