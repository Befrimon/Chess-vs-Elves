extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 500
var MOVE_TEMPLATE :Array[Vector2] = []

const SKILL_TEMPLATE :Array[Vector2] = [Vector2(1, 1), Vector2(1, 0), Vector2(1, -1)]

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.allow_move = false
	parent.stun_cooldown = INF
	
	for i in range(1, 6):
		MOVE_TEMPLATE.append(Vector2(i, i))
		MOVE_TEMPLATE.append(Vector2(-i, i))
		MOVE_TEMPLATE.append(Vector2(i, -i))
		MOVE_TEMPLATE.append(Vector2(-i, -i))
	
	for pos in SKILL_TEMPLATE:
		var collider = CollisionShape2D.new()
		collider.shape = Global.HITBOX
		collider.position = pos * Global.TILE_SIZE / parent.scale
		collider.scale = parent.hitbox.scale
		parent.skill_area.add_child(collider)
	
	for pos in MOVE_TEMPLATE:
		var cell = Global.MOVE_CELL.duplicate().instantiate()
		cell.position = (Global.POS_DELTA + pos * Global.TILE_SIZE) / parent.scale
		cell.set_meta("delta", pos)
		cell.scale = Global.TILE_SIZE / cell.sprite_frames.get_frame_texture("default", 0).get_size() / parent.scale
		parent.move_cells.add_child(cell)

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
	return "Heal: %s\nCooldown: %s" % \
	  [Global.ENTITY_PARAM[parent.full_id]["level%s" % parent.level]["value"], 
	  str(int(parent.skill_cooldown-Global.timer))]
