extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 500
var MOVE_RANGE :Dictionary = {
	Vector2(1, 1): 10, Vector2(-1, -1): 10,
	Vector2(1, -1): 10, Vector2(-1, 1): 10
}

const SKILL_RANGE :Array[Vector2] = [Vector2(1, 1), Vector2(1, 0), Vector2(1, -1)]

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.allow_move = false
	parent.stun_cooldown = INF

func get_skill_target():
	var target :Entity = null
	
	for body in parent.skill_area.get_overlapping_bodies():
		if body.type != "figure": continue
		if !target and body.hits != body.max_hits:
			target = body
		elif target and target.hits/target.max_hits > body.hits/body.max_hits:
			target = body
	
	return target

func get_unique_info() -> String:
	return "Лечение: %s +%s\nОткат: %s" % \
	  [Global.ENTITY_PARAM[parent.full_id]["level%s" % parent.level]["value"], 
	  parent.buff_value, str(int(parent.skill_cooldown-Global.timer))]
