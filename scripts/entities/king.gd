extends Node

var parent : Entity

var hp : float

func _init(king_parent: Entity):
	## Set variables
	parent = king_parent
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

