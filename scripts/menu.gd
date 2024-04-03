extends Control


func _ready():
	get_node("PlayBtn").pressed.connect(Global.change_scene.bind("new_game"))
	get_node("LoadBtn").pressed.connect(Global.change_scene.bind("load_game"))
	get_node("ExitBtn").pressed.connect(get_tree().quit)
