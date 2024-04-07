extends Node

## Variables
const MAP_POS = Vector2(260, 265)
const PREV_ID = {
	"king_figure": Vector2(6, 4),
	"pawn_figure": Vector2(5, 0)
}

var preview_map : TileMap
var shadow : String
var enabled : bool


func figure_preview(pos: Vector2):
	if pos.x < MAP_POS.x or pos.y < MAP_POS.y or !enabled:
		preview_map.clear()
		return
	
	var prev_pos = (pos - MAP_POS)
	prev_pos = Vector2(int(prev_pos.x / 80), int(prev_pos.y / 80))
	preview_map.clear()
	preview_map.set_cell(0, prev_pos, 0, PREV_ID[shadow])

func on_map(pos: Vector2):
	return enabled and pos.x > MAP_POS.x and pos.y > MAP_POS.y

func toggle(activator, name: String):
	enabled = activator.button_pressed
	shadow = name
	preview_map.clear()
