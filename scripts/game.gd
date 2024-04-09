extends Node2D

var interface : Control
var cur_selector : AnimatedSprite2D

func _ready():
	EntityController.controller_group = get_node("Controllers")
	EntityController.elfs_group = get_node("Elfs")
	EntityController.figures_group = get_node("Figures")
	Preview.preview_map = get_node("PreviewMap")
	Global.game_root = self
	
	interface = get_node("GameInterface")

	if Global.game_state == "GenNew":
		EntityController.pregen_rooks()
		Global.game_state = "Run"
	
	elif Global.game_state == "LoadNew":
		pass


var timer = 0
var tick = randi_range(EntityController.MIN_TICK, EntityController.MAX_TICK)
func _process(delta):
	timer += delta
	
	if timer >= tick:
		tick = randi_range(EntityController.MIN_TICK, EntityController.MAX_TICK)
		timer = 0
		EntityController.new_entity("base_elf", Vector2(1660, Preview.MAP_POS.y-40 + 80*randi_range(1, 6)))

func _input(event):
	if event is InputEventMouseMotion:
		if Preview.enabled:
			Preview.figure_preview(event.position)
	if event is InputEventMouseButton:
		if !Preview.enabled:
			var fig = EntityController.get_figure(event.position)
			if not fig: 
				interface.change_info(null)
				return
			interface.change_info(fig)
		if event.button_index == 1 and Preview.on_map(event.position):
			EntityController.new_entity(Preview.shadow, EntityController.convert_pos(event.position))
			interface.toggle_menu(true)
		


