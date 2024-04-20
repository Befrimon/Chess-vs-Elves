class_name Entity extends CharacterBody2D

enum Type {UNKNOWN, ELF, FIGURE}
enum Actions {UPGRADE = 1, SELL = 2, REST = 3}
enum Name {UNKNOWN, ROOK = 0, PAWN = 1, KING = 2, BISHOP = 3, KNIGHT = 4, QUEEN = 5,
			FOREST_ELF = 6, DARK_ELF = 7}

## Declare variables
var data :Dictionary

var type :Type = Type.UNKNOWN
var iname :Name = Name.UNKNOWN
var damage :float = 0  # The damage received
var bonus_hits :int = 0
var bonus_value :float = 0
var level :int = 1
var exp :int = 0
var skill_cooldown :float = 0
var rest_active :bool = false

var disabled_actions :Array[Actions] = [Actions.UPGRADE]

# Move param
var speed :int
var direction :Vector2
var target :Vector2
var allow_move :bool = true
var stun_time :float = 0

# Child nodes
var texture :AnimatedSprite2D = AnimatedSprite2D.new()
var highlighting :AnimatedSprite2D = AnimatedSprite2D.new()
var hitbox :CollisionShape2D = CollisionShape2D.new()
var skillbox :Area2D = Area2D.new()
var hpbar :Sprite2D = Sprite2D.new()
var hpvalue :Sprite2D = Sprite2D.new()

func _init(pos :Vector2, index :int) -> void:
	# Configure texture
	texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture.sprite_frames = load("res://animations/%s.tres" % name.split("-")[0])
	texture.scale = Vector2(1, 1) * Global.config["game_map"]["tile"]\
					/ texture.sprite_frames.get_frame_texture("idle", 0).get_size()
	texture.z_index = 1
	texture.play("idle")
	add_child(texture)
	
	highlighting.sprite_frames = load("res://animations/highlighting.tres")
	highlighting.scale = Vector2(1, 1) * Global.config["game_map"]["tile"]\
					/ highlighting.sprite_frames.get_frame_texture("default", 0).get_size()
	highlighting.play("default")
	highlighting.position = Vector2(0, 0.2*Global.config["game_map"]["tile"])
	highlighting.visible = false
	add_child(highlighting)

	# Configure hitbox
	hitbox.shape = RectangleShape2D.new()
	hitbox.shape.size = Vector2(.8, .8) * Global.config["game_map"]["tile"]
	add_child(hitbox)
	
	# Configure skill area
	for direction in data["skillbox"]:
		var box :CollisionShape2D = CollisionShape2D.new()
		box.shape = RectangleShape2D.new()
		box.shape.size = Vector2(.8, .8) * Global.config["game_map"]["tile"]
		box.position = str_to_var(direction) * data["skillbox"][direction] * Global.config["game_map"]["tile"]
		skillbox.add_child(box)
	add_child(skillbox)
	
	hpbar.texture = load("res://textures/hpbar.png")
	hpbar.scale = Vector2(.75, .15) * Global.config["game_map"]["tile"] / hpbar.texture.get_size()
	hpbar.position = Vector2(0, -.35) * Global.config["game_map"]["tile"]
	hpbar.z_index = 1
	
	hpvalue.texture = load("res://textures/hpvalue.png")
	
	hpbar.add_child(hpvalue)
	add_child(hpbar)
	
	# Set variables
	position = Global.position_normilize(pos)*Global.config["game_map"]["tile"]
	target = position
	skill_cooldown = data["level1"]["cooldown"]

var just_end :bool = false
func _physics_process(delta :float) -> void:
	if position.distance_to(target) > 10 and allow_move:
		just_end = true
		direction = position.direction_to(target)
		velocity = direction * speed
		move_and_slide()
	elif allow_move:
		position = target
		if just_end and type == Type.FIGURE:
			get_node("/root/Game").busy_cells.append(Global.position_normilize(position))
			get_node("/root/Game").selected_entity = self
			just_end = false

func _process(delta :float) -> void:
	if !allow_move:
		stun_time -= delta
	if stun_time < 0:
		stun_time = 0
		allow_move = true
	
	if rest_active and damage > 0:
		change_hits(-0.0005)
	
	hpvalue.scale.x = (data["level%s"%level]["hits"]-damage) / data["level%s"%level]["hits"]
	hpvalue.position.x = -1.7*(1-hpvalue.scale.x)*hpbar.scale.x
	
	if skill_cooldown <= 0 and !rest_active:
		skill_cooldown = 0
		skill()
	elif !rest_active:
		skill_cooldown -= delta
	
	if exp == Global.config["levels"][level] and Entity.Actions.UPGRADE in disabled_actions:
		disabled_actions.remove_at(disabled_actions.find(Entity.Actions.UPGRADE))

func get_info() -> String:
	return "Название: %s\nУровень: %s (%s/%s)\nХиты: %s/%s"\
	% [data["name"], level, exp, Global.config["levels"][level], 
		data["level%s"%level]["hits"]-int(damage*100)/100, data["level%s"%level]["hits"]]

func change_hits(raw_value :float, target :Entity = null) -> void:
	damage += randf_range(.1, 1)*raw_value
	if damage > data["level%s" % level]["hits"] + bonus_hits:
		damage = -1
		kill()
	elif damage < 0:
		damage = 0
	if target == null: return
	
	if data["counterattack"] and damage > data["level%s" % level]["hits"] + bonus_hits:
		target.change_hits(.1*data["level%s" % level]["attack"])
	elif data["counterattack"]:
		target.change_hits(.2*(data["level%s" % level]["attack"] + bonus_value))
		bonus_value = 0

func skill() -> void:
	pass

func kill() -> void:
	var game :Game = get_node("/root/Game")
	
	game.busy_cells.remove_at(game.busy_cells.find(Global.position_normilize(position)))
	if type == Type.FIGURE:
		game.total_entities[iname] -= 1
	
	get_parent().remove_child(self)
	set_physics_process(false)
	queue_free()
