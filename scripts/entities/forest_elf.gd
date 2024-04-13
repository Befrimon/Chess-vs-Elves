extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 70

const SKILL_TEMPLATE :Array[Vector2] = [Vector2(-.3, 0)]
var target :Entity

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.direction = Vector2(-1, 0)
	
	parent.texture.flip_h = true
	parent.texture.play("run")
	
	for cell in SKILL_TEMPLATE:
		var collider = CollisionShape2D.new()
		collider.shape = Global.HITBOX
		collider.position = cell * Global.TILE_SIZE / parent.scale
		collider.scale = parent.hitbox.scale
		parent.skill_area.add_child(collider)

func _process(delta):
	if parent.position.x < 300:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func get_skill_target() -> Entity:
	if is_instance_valid(target):
		return target
	
	for body in parent.skill_area.get_overlapping_bodies():
		if body.type == "figure":
			target = body
			return body
	
	return null

func get_unique_info() -> String:
	return ""

