extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 500
const MOVE_TEMPLATE :Array[Vector2] = [
	Vector2(2, 1), Vector2(1, 2),
	Vector2(-2, 1), Vector2(-1, 2),
	Vector2(2, -1), Vector2(1, -2),
	Vector2(-2, -1), Vector2(-1, -2)
]

const SKILL_TEMPLATE :Array[Vector2] = [Vector2(1, 1), Vector2(2, 1), Vector2(1, -1), Vector2(2, -1)]
var target :Entity

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.allow_move = false
	parent.stun_cooldown = INF
	
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

func get_skill_target() -> Entity:
	if is_instance_valid(target):
		return target
	
	for body in parent.skill_area.get_overlapping_bodies():
		if body.type == "elf":
			target = body
			return body
	
	return null

func get_unique_info() -> String:
	return "Damage: %s" % \
	  str(-1*Global.ENTITY_PARAM[parent.full_id]["level%s" % parent.level]["value"])
