class_name Rook extends Entity

var audio :AudioStreamPlayer2D = AudioStreamPlayer2D.new()

func _init(pos :Vector2, index :int) -> void:
	name = "rook-%s" % index
	data = JSON.parse_string(FileAccess.get_file_as_string("res://sources/entities/rook.json"))
	
	super(pos, index)
	
	# Configure audio
	audio.stream = load("res://sounds/the_rook.mp3")
	add_child(audio)
	
	# Configure node
	hpbar.visible = false
	disabled_actions = [Actions.UPGRADE, Actions.SELL, Actions.REST]
	type = Type.FIGURE
	iname = Name.ROOK
	speed = 500

func _physics_process(delta :float) -> void:
	super(delta)
	if position.x >= Global.config["elf_start_x"]:
		kill()

func skill() -> void:
	if len(skillbox.get_overlapping_bodies()) <= 1:
		return
	if !audio.playing:
		audio.play()
	allow_move = true
	target = Vector2(Global.config["elf_start_x"], position.y)
	for entity in skillbox.get_overlapping_bodies():
		entity.change_hits(1000 if entity != self else 0)
