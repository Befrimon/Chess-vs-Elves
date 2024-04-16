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
	var target_candidate = [null]
	for body in parent.skill_area.get_overlapping_bodies():
		if body.type == "elf":
			target_candidate.append(body)
	
	if target in target_candidate and target != null:
		return target
	target = target_candidate[-1]
	return target

func get_unique_info() -> String:
	return "Урон: %s +%s" % [\
	  str(-1*Global.ENTITY_PARAM[parent.full_id]["level%s" % parent.level]["value"]),
	  parent.buff_value
	]
