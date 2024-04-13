extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 500
const MOVE_TEMPLATE :Array[Vector2] = [
	Vector2(1, -1),Vector2(1, 0),Vector2(1, 1),
	Vector2(-1, -1),Vector2(-1, 0),Vector2(-1, 1),
	Vector2(0, 1),Vector2(0, -1)
]

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.allow_move = false
	parent.stun_cooldown = INF
	
	for pos in MOVE_TEMPLATE:
		var cell = Global.MOVE_CELL.duplicate().instantiate()
		cell.position = (Global.POS_DELTA + pos * Global.TILE_SIZE) / parent.scale
		cell.set_meta("delta", pos)
		cell.scale = Global.TILE_SIZE / cell.sprite_frames.get_frame_texture("default", 0).get_size() / parent.scale
		parent.move_cells.add_child(cell)

func get_skill_target():
	return "crowns"

func get_unique_info() -> String:
	return "Crowns: %s\nCooldown: %s" % \
	  [Global.ENTITY_PARAM[parent.full_id]["level%s" % parent.level]["value"], 
	  str(int(parent.skill_cooldown-Global.timer))]
