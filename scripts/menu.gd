extends Control


func _ready():
	## Connect button functions
	var link_buttons = get_node("LinkButtons")
	get_tree().paused = false
	for button in link_buttons.get_child_count():
		var button_obj = link_buttons.get_child(button)
		button_obj.pressed.connect(open_game.bind(button_obj.get_meta("scene_action")))

func open_game(action :String):
	match action:
		"new_game":
			print("[INFO] Configuring new game")
			Global.timer = 0
			Global.busy_cells = []
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		"load_game":
			pass  # TODO
		"quit_game":
			print("[INFO] Closing game")
			get_tree().quit()
