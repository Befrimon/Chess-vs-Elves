extends Control

var spw_buttons : Control
var menu_opened : bool


func _ready():
	spw_buttons = get_node("SpawnButttons")
	menu_opened = true
	
	get_node("SpawnBtn").pressed.connect(toggle_menu)
	get_node("PauseBtn").pressed.connect(Global.pause)
	for btn in spw_buttons.get_child_count():
		var cur_btn = spw_buttons.get_child(btn)
		cur_btn.pressed.connect(Preview.toggle.bind(cur_btn, cur_btn.name))

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

