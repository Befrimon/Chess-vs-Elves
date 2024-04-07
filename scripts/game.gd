extends Node2D

func _ready():
	EntityController.controller_group = get_node("Controllers")
	Preview.preview_map = get_node("PreviewMap")
	Global.game_root = self

	if Global.game_state == "GenNew":
		EntityController.pregen_rooks(self)
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
		EntityController.new_entity(self, "elf", Vector2(1660, 310 + 80*randi_range(0, 5)))

func _input(event):
	if event is InputEventMouseMotion:
		Preview.figure_preview(event.position)
	if event is InputEventMouseButton and event.button_index == 1 and Preview.check_place(event.position):
		EntityController.new_entity(self, Preview.shadow, Preview.convert_pos(event.position))
		get_node("GameInterface").toggle_menu(true)


