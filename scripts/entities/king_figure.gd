extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 500
const MOVE_RANGE :Dictionary = {
	Vector2(-1, 1): 1, Vector2(0, 1): 1, Vector2(1, 1): 1,
	Vector2(-1, -1): 1, Vector2(0, -1): 1, Vector2(1, -1): 1,
	Vector2(1, 0): 1, Vector2(-1, 0): 1
}

const SKILL_RANGE :Array[Vector2] = []

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.allow_move = false
	parent.stun_cooldown = INF

func get_skill_target():
	return "crowns"

func get_unique_info() -> String:
	return "Короны: %s +%s (%s сек)" % \
	  [Global.ENTITY_PARAM[parent.full_id]["level%s" % parent.level]["value"],
	  parent.buff_value, str(int(parent.skill_cooldown-Global.timer))
	]
