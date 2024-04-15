extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 500
const MOVE_RANGE :Dictionary = {
	Vector2(1, 2): 1, Vector2(1, -2): 1, Vector2(2, 1): 1, Vector2(2, -1): 1,
	Vector2(-1, 2): 1, Vector2(-1, -2): 1, Vector2(-2, 1): 1, Vector2(-2, -1): 1,
}

const SKILL_RANGE :Array[Vector2] = [Vector2(1, 1), Vector2(2, 1), Vector2(1, -1), Vector2(2, -1)]
var target :Entity

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.allow_move = false
	parent.stun_cooldown = INF

func get_skill_target() -> Entity:
	if is_instance_valid(target):
		return target
	
	for body in parent.skill_area.get_overlapping_bodies():
		if body.type == "elf":
			target = body
			return body
	
	return null

func get_unique_info() -> String:
	return "Damage: %s +%s" % [\
	  str(-1*Global.ENTITY_PARAM[parent.full_id]["level%s" % parent.level]["value"]),
	  parent.buff_value
	]
