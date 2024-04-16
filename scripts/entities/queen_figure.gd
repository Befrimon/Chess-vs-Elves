extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 500
const MOVE_RANGE :Dictionary = {
	Vector2(-1, 1): 20, Vector2(0, 1): 20, Vector2(1, 1): 20,
	Vector2(-1, -1): 20, Vector2(0, -1): 20, Vector2(1, -1): 20,
	Vector2(1, 0): 20, Vector2(-1, 0): 20
}

const SKILL_RANGE :Array[Vector2] = [
	Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1),
	Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
	Vector2(1, 0), Vector2(-1, 0)
]

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.allow_move = false
	parent.stun_cooldown = INF

func get_skill_target() -> Array[Entity]:
	var target :Array[Entity] = []
	
	for body in parent.skill_area.get_overlapping_bodies():
		if body.type != "figure": continue
		target.append(body)
	
	return target

func get_unique_info() -> String:
	return "Бонус лечения/урона: %s\nБонус корон: %s" % Global.ENTITY_PARAM[parent.full_id]["level%s" % parent.level]["value"]
