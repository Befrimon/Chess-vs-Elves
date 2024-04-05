extends Node2D

func pregen_rooks():
	for y in range(310, 711, 80):
		Entity.new_figure(self, "rook", Vector2(220, y))


func _ready():
	if Global.game_state == "New":
		pregen_rooks()


var timer = 0
var tick = randi_range(Global.MIN_TICK, Global.MAX_TICK)
func _process(delta):
	timer += delta
	
	if timer >= tick:
		tick = randi_range(Global.MIN_TICK, Global.MAX_TICK)
		timer = 0
		Entity.new_elf(self)


