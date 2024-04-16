extends Node

## Declare variables
var parent :Entity

# Move properties
const SPEED :int = 70
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
	var target_candidate = [null]
	for body in parent.skill_area.get_overlapping_bodies():
		if body.type == "figure":
			target_candidate.append(body)
	
	if target in target_candidate and target != null:
		return target
	target = target_candidate[-1]
	return target

func get_unique_info() -> String:
	return ""

