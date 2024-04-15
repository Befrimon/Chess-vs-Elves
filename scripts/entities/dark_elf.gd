extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 80
const MOVE_RANGE :Dictionary = {}

const SKILL_RANGE :Array[Vector2] = [Vector2(-1, 0)]
var target :Entity

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.direction = Vector2(-1, 0)
	
	parent.texture.flip_h = true
	parent.texture.play("run")

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

