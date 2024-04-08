extends Node

var parent : Entity
var the_rook : bool

func _init(rook_parent: Entity):
	## Set variables
	parent = rook_parent
	the_rook = false
	
	## Set animation
	parent.texture.play("idle")
	parent.hpbar.visible = false
	
	## Set audio
	parent.audio.stream = load("res://audio/rook.mp3")

func _physics_process(delta):
	parent.move_and_slide()
	if the_rook:
		## Move and kill all in line
		parent.velocity = Vector2(EntityController.ROOK_SPEED, 0)
		for i in parent.get_slide_collision_count():
			var collision = parent.get_slide_collision(i)
			collision.get_collider().kill()
		if parent.position.x > 1600:
			parent.kill()

	else:
		## Detect any collision
		parent.velocity = Vector2.ZERO
		if parent.get_slide_collision_count() > 0:
			print("Turn on the ROOOOOK!")
			parent.audio.play()
			the_rook = true

func get_info():
	return [parent.dname, "inf", "State" , "ready"]

