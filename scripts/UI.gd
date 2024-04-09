extends Control

var spw_buttons : Control
var figure_info : TextEdit
var crown_label : Label
var menu_opened : bool

var spawn_group : ButtonGroup
var current_figure : Entity

func _ready():
	spw_buttons = get_node("SpawnButttons")
	figure_info = get_node("FigureInfo")
	crown_label = get_node("CrownLabel")
	menu_opened = true
	
	spawn_group = load("res://prefabs/figure-creators.tres")
	
	get_node("SpawnBtn").pressed.connect(toggle_menu)
	get_node("PauseBtn").pressed.connect(Global.pause)
	
	var y_pos = 70
	for btn in EntityController.costs:
		if btn == "rook_figure": continue
		
		var ttext = EntityController.costs[btn]
		var cur_btn = Button.new()
		cur_btn.name = btn
		cur_btn.text = "%s - %s" % ttext
		cur_btn.size = Vector2(150, 50)
		cur_btn.position = Vector2(10, y_pos)
		cur_btn.pressed.connect(Preview.toggle.bind(cur_btn, cur_btn.name))
		cur_btn.button_group = spawn_group
		cur_btn.toggle_mode = true
		spw_buttons.add_child(cur_btn)
		y_pos += 60

func _process(delta):
	crown_label.text = "Crowns: %s" % EntityController.crown_count
	figure_info.text = "" if !(current_figure and current_figure.selector.visible) else current_figure.controller.get_info()

func toggle_menu(menu_state : bool = !menu_opened):
	menu_opened = menu_state
	for i in range(spw_buttons.get_child_count()):
		var cur_btn : Button = spw_buttons.get_child(i)
		cur_btn.button_pressed = false
		Preview.toggle(cur_btn, "")
		if menu_opened:
			cur_btn.position = Vector2(10, 80 + 60*i)
		if !menu_opened:
			cur_btn.position = Vector2(10, 0)

func change_info(entity: Entity):
	current_figure = entity

