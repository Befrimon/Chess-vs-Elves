extends TileMapLayer

const WIDTH			:int = 24
const HEIGHT		:int = 14
const MAX_DEAD_TIME	:int = 3

var tiles :Array[Vector2]
var deadtime :Array[float]

func _ready() -> void:
	randomize()
	
var timer :float = 0
var seconds :int = 0
func _process(delta :float) -> void:
	timer += delta
	while (not deadtime.is_empty() and deadtime[0] <= timer):
		erase_cell(tiles[0])
		deadtime.pop_front()
		tiles.pop_front()
		
	if (seconds > timer): return
	seconds += 1
	var pos :Vector2 = Vector2(randi() % WIDTH, randi() % HEIGHT)
	var dead :int = 1 + randi() % MAX_DEAD_TIME
	
	set_cell(pos, int(pos.x+pos.y) % 2, Vector2.ZERO)
	tiles.append(pos)
	deadtime.append(timer+dead)
	
