extends Node

var parent : Entity

var crown_gen : int
var gen_cooldown : int
var hp : float

func _init(king_parent: Entity):
	## Set variables
	parent = king_parent
	crown_gen = 50
	gen_cooldown = 10
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

var timer = 0
func _process(delta):
	timer += delta
	if timer >= gen_cooldown:
		print("King generate %s crowns" % crown_gen)
		EntityController.crown_count += crown_gen
		timer = 0

func get_info():
	return [parent.dname, str(hp*parent.hpbar.scale.x), "Cooldown", str(int(gen_cooldown-timer))]


