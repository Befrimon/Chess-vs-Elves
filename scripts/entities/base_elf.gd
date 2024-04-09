extends Node

var parent : Entity
var rand : bool

func _init(elf_parent: Entity):
	## Set physics
	parent = elf_parent
	
	## Set animation
	parent.scale.x *= -1
	parent.texture.play("run")
	parent.texture.process_mode = Node.PROCESS_MODE_PAUSABLE
	parent.hpbar.visible = false
	
	if randi_range(1, 100) > 90:
		rand = true

func _physics_process(delta):
	parent.velocity = Vector2(-1*EntityController.ELF_SPEED, 0)
	parent.move_and_slide()
	
	if parent.position.x <= 200:
		print("Win ", parent.name)
		Global.game_over()

func get_info():
	return "
	Name: Base elf
	Type: elf
	Cocaina???
	"
