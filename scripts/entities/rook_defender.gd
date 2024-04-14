extends Node

## Declare variables
var parent :Entity
var audio :AudioStreamPlayer2D

# Move properties
const SPEED :int = 500
var run_mode :bool

func _init(parent_obj :Entity):
	## Assign variables
	parent = parent_obj
	parent.direction = Vector2(1, 0)
	
	parent.allow_move = false
	parent.stun_cooldown = INF
	
	## Create and config unique nodes
	audio = AudioStreamPlayer2D.new()
	audio.stream = load("res://sounds/the_rook.mp3")
	parent.add_child(audio)

func _physics_process(delta):
	## Kill rook if he go too far
	if parent.position.x > 2100:
		parent.kill()
		
	## Enable run mode if collide
	if parent.get_slide_collision_count() > 0:
		parent.get_slide_collision(0).get_collider().kill()
		if !parent.allow_move: 
			audio.play()
		parent.allow_move = true

func get_skill_target():
	return ""

func get_unique_info() -> String:
	return ""
