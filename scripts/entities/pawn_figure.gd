extends Node

var parent : Entity
var eat_area : Area2D

var kill_count : int
var hp : float

func _init(pawn_parent: Entity):
	## Set variables
	parent = pawn_parent
	kill_count = 2
	hp = 3
	
	## Set animation
	parent.texture.play("idle")

func _physics_process(delta):
	parent.velocity = Vector2.ZERO
	parent.move_and_slide()
	if parent.get_slide_collision_count() > 0:
		parent.hpbar.scale.x -= delta / hp
	
	if parent.hpbar.scale.x <= 0:
		parent.kill()
	
	for body in eat_area.get_overlapping_bodies():
		if "elf" not in body.bid: continue
		
		var new_pos = EntityController.convert_pos(body.position)
		if not EntityController.check_close(new_pos):
			return
		parent.position = new_pos
		kill_count -= 1
		body.kill()
	if kill_count == 0:
		parent.kill()

func get_info():
	return "
	Name: Pawn
	Type: figure
	Hits: %s
	Uses: %s
	" % [int(hp), kill_count]
