extends Control

var parent :Game

var spawn_btn_parent :Control
var spawn_group :ButtonGroup

var timer_label :Label
var crown_label :Label
var info_panel :RichTextLabel

var active :Entity

func _ready():
	## Assign variables
	spawn_btn_parent = get_node("SpawnButtons")
	spawn_group = ButtonGroup.new()
	spawn_group.allow_unpress = true
	
	timer_label = get_node("PaperRect/TimerLabel")
	crown_label = get_node("PaperRect/CrownLabel")
	info_panel = get_node("InfoPanel")
	
	var y_pos :int = 0
	for entity in Global.ENTITY_PARAM:
		if "figure" not in entity:
			continue
		
		var info = Global.ENTITY_PARAM[entity]
		
		var spawn_button = TextureButton.new()
		spawn_button.name = entity
		spawn_button.texture_normal = load("res://textures/GUI/button_normal.png")
		spawn_button.texture_pressed = load("res://textures/GUI/button_pressed.png")
		spawn_button.stretch_mode = TextureButton.STRETCH_SCALE
		spawn_button.toggle_mode = true
		spawn_button.button_group = spawn_group
		spawn_button.size = Vector2(250, 80)
		spawn_button.position = Vector2(0, y_pos)
		spawn_button.pressed.connect(change_preview.bind(spawn_button, entity))
		
		var button_label = Label.new()
		button_label.text = "%s - %s" % [info["name"], info["level1"]["cost"]]
		button_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		button_label.add_theme_font_size_override("font_size", 32)
		button_label.size = Vector2(250, 70)
		spawn_button.add_child(button_label)
		
		spawn_btn_parent.add_child(spawn_button)
		y_pos += 90
	
	get_node("EntityButtons/UpgradeButton").pressed.connect(upgrade_figure)
	get_node("EntityButtons/KillButton").pressed.connect(kill_figure)
	# get_node("EntityButtons/MoveButton").pressed.connect(change_move.bind(get_node("EntityButtons/MoveButton")))
	get_node("HelpButton").pressed.connect(help_open)
	get_node("ExitButton").pressed.connect(get_tree().change_scene_to_file.bind("res://scenes/menu.tscn"))
	get_node("PauseButton").pressed.connect(pause)

func _process(delta):
	timer_label.text = "%s %s секунд" % [
		Global.WAVES[parent.wave]["name"],
		str(int(parent.wave_time - Global.timer)) if parent.wave_time < 600 else "0"
	]
	crown_label.text = "Короны: %s" % str(parent.crown_count)

func upgrade_figure():
	if active == null or active.type != "figure":
		return
	var cost = Global.ENTITY_PARAM[active.full_id]["level%s" % str(active.level+1)]["cost"]
	var exp = Global.LEVEL_EXP[active.level]
	if parent.crown_count < cost or active.exp < exp:
		print("[ERROR] Not enough crowns or EXP")
		return
	parent.crown_count -= cost
	active.levelup()

func kill_figure():
	if active == null or active.type != "figure":
		return
	parent.crown_count += Global.ENTITY_PARAM[active.full_id]["level1"]["cost"]/2
	active.kill()

func help_open():
	parent.help_menu.visible = true
	get_tree().paused = true

func pause():
	get_tree().paused = !get_tree().paused

func change_move(btn :Button):
	parent.active.move_cells.visible = true

func change_preview(btn :TextureButton, ename :String):
	if parent.active and is_instance_valid(parent.active):
		parent.active.move_cells.visible = false
	parent.preview_enable = btn.button_pressed
	parent.preview_figure.set_figure(ename)

func update_figure_info(entity :Entity):
	if entity:
		active = entity
		info_panel.text = entity.get_info()
	else:
		info_panel.text = ""
