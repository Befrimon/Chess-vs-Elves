extends Control

var tile_map :TileMap

func _ready():
	## Connect button functions
	var link_buttons = get_node("LinkButtons")
	get_tree().paused = false
	for button in link_buttons.get_child_count():
		var button_obj = link_buttons.get_child(button)
		button_obj.pressed.connect(open_game.bind(button_obj.get_meta("scene_action")))
	
	tile_map = get_node("TileMap")
	tile_map.scale = Global.TILE_SIZE / Vector2(tile_map.tile_set.tile_size)
	for x in range(23):
		for y in range(13):
			tile_map.set_cell(0, Vector2(x, y), 2, Vector2.ZERO)

var timer = {}
var count = 0.
var left = 0.
func _process(delta):
	count += delta
	if count >= left:
		left += .5
		var x = randi_range(0, 22)
		var y = randi_range(0, 12)
		while timer.find_key(Vector2(x, y)):
			x = randi_range(0, 23)
			y = randi_range(0, 13)
		
		var time = randi_range(1, 5)
		var tile = randi_range(0, 1)
		var figure = randi_range(0, 5)
		
		tile_map.set_cell(0, Vector2(x, y), tile, Vector2.ZERO)
		timer[Vector2(x, y)] = count+time
	
	for cell in timer:
		if timer[cell] <= count:
			tile_map.set_cell(0, cell, 2, Vector2.ZERO)
			timer.erase(cell)
	

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
