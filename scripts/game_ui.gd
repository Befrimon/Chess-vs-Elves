extends Control

func _ready() -> void:
	var y_pos :int = 0
	var fid :int = 1
	for figure in Global.config["figures"]:
		var data = JSON.parse_string(FileAccess.get_file_as_string("res://sources/entities/%s.json" % figure))
		var fig_button :TextureButton = load("res://prefabs/spawn_button.tscn").instantiate()
		fig_button.name = figure
		fig_button.position = Vector2(0, y_pos)
		fig_button.get_child(0).text = "%s - %s" % [data["name"], data["level1"]["cost"]]
		fig_button.button_group = load("res://sources/spawn_buttons.tres")
		fig_button.toggled.connect(_on_btn_toggle.bind("SpawnButtons/%s" % fig_button.name))
		fig_button.toggled.connect(get_node("/root/Game").toggle_preview.bind(fid))
		# fig_button.pressed.connect()
		get_node("SpawnButtons").add_child(fig_button)
		
		fig_button.set_meta("eid", fid)
		fig_button.set_meta("crown", data["level1"]["cost"])
		fig_button.set_meta("max", data["max_count"])
		
		y_pos += 90
		fid += 1

## Move button text/icon on click
func _on_btn_down(btn_name :String) -> void:
	get_node(btn_name).get_child(0).position.y += 8

func _on_btn_up(btn_name :String) -> void:
	get_node(btn_name).get_child(0).position.y -= 8

func _on_btn_toggle(toggled_on :bool, btn_name :String) -> void:
	if toggled_on:
		get_node(btn_name).get_child(0).position.y += 8
	else:
		get_node(btn_name).get_child(0).position.y -= 8
