extends CharacterBody2D
class_name Entity

## Declare variables
# Child nodes
var controller :Node
var texture :AnimatedSprite2D
var hitbox :CollisionShape2D
var highlighting :AnimatedSprite2D
var move_cells :Node2D
var skill_area :Area2D

# Entity properties
var node_name :String
var display_name :String
var full_id :String
var type :String

var level :int
var exp :int
var max_hits :float
var hits :float
var skill_cooldown :float
var buff_value :int

# Move param
var direction :Vector2
var target :Vector2
var allow_move :bool
var stun_cooldown :float

func init(sname :String, eid :String, pos :Vector2):
	## Assign variables
	# Get child nodes
	texture = get_node("Texture")
	hitbox = get_node("Hitbox")
	highlighting = get_node("Highlighting")
	move_cells = get_node("MoveCells")
	skill_area = get_node("SkillArea")
	
	# Configure texture
	texture.sprite_frames = load("res://animations/%s.tres" % eid)
	texture.play("idle")
	
	# Configure node
	name = sname
	position = pos
	scale = Global.TILE_SIZE / texture.sprite_frames.get_frame_texture("idle", 0).get_size().x
	Global.busy_cells.append(position)
	add_to_group(eid)
	
	# Configure child nodes
	hitbox.scale = Global.TILE_SIZE / scale.x /2
	highlighting.position = Global.POS_DELTA / scale.x
	highlighting.scale = texture.sprite_frames.get_frame_texture("idle", 0).get_size() / \
		highlighting.sprite_frames.get_frame_texture("idle", 0).get_size()
	
	# Set properties
	full_id = eid
	node_name = sname
	display_name = Global.ENTITY_PARAM[eid]["name"]
	type = eid.split("_")[1]
	
	level = 1
	max_hits = Global.ENTITY_PARAM[eid]["level1"]["hits"]
	hits = Global.ENTITY_PARAM[eid]["level1"]["hits"]
	skill_cooldown = Global.timer+Global.ENTITY_PARAM[eid]["level1"]["cooldown"]
	
	allow_move = true
	stun_cooldown = 0
	
	# Set controller
	controller = load("res://scripts/entities/%s.gd" % eid).new(self)
	controller.name = "Controller"
	add_child(controller)
	
	for i in controller.SKILL_RANGE:
		var collider = CollisionShape2D.new()
		collider.shape = Global.HITBOX
		collider.position = i * Global.TILE_SIZE / scale
		collider.scale = hitbox.scale
		skill_area.add_child(collider)

func _process(delta):
	if get_tree().paused:
		return
	
	if Global.timer > skill_cooldown:
		var res = controller.get_skill_target()
		var value = Global.ENTITY_PARAM[full_id]["level%s" % str(level)]["value"]
		var skill_type = Global.ENTITY_PARAM[full_id]["type"]
		if skill_type != "buffer":
			value += buff_value
			buff_value = 0
		
		if res != null:
			skill_cooldown += Global.ENTITY_PARAM[full_id]["level%s" % str(level)]["cooldown"]
		else:
			skill_cooldown += 1
		
		if res is String and res == "crowns":
			get_node("/root/Game").crown_count += value
			if exp < Global.LEVEL_EXP[level]:
				exp += 10
		elif skill_type == "attacker" and res is Entity:
			res.change_hits(value)
			if Global.ENTITY_PARAM[res.full_id]["type"] == "attacker":
				var attack = Global.ENTITY_PARAM[res.full_id]["level%s" % res.level]["value"]
				change_hits(attack/5 if res.hits > 0 else attack/10)
				if exp < Global.LEVEL_EXP[level] and res.type == "elf" and res.hits <= 0:
					exp += Global.ENTITY_PARAM[res.full_id]["exp_value"]
		elif skill_type == "healer" and res is Entity:
			res.change_hits(value)
			if exp < Global.LEVEL_EXP[level]:
				exp += 25
		elif res is Array[Entity]:
			for entity in res:
				entity.buff_value = value[1] if entity.full_id == "king_figure" else value[0]
	

func _physics_process(delta):
	if get_tree().paused:
		return
	
	if stun_cooldown > 0:
		stun_cooldown -= delta
	elif stun_cooldown < 0:
		stun_cooldown = 0
		allow_move = true
		if type == "elf":
			texture.play("run")
	
	if global_position.distance_to(target) < 10:
		highlighting.visible = true
		name = "Active"
		position = target
		move_cells.visible = true
		target = Vector2.ZERO
	
	if target != Vector2.ZERO:
		direction = global_position.direction_to(target)
		velocity = direction * controller.SPEED
	else:
		velocity = direction * controller.SPEED * int(allow_move)
	move_and_slide()

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		var entity_click = Rect2(position - Global.TILE_SIZE / 2, Global.TILE_SIZE).has_point(event.position)
		
		highlighting.visible = entity_click
		name = "Active" if entity_click else node_name
		
		for cell in move_cells.get_children():
			if !move_cells.visible: break
			if cell.visible and Rect2(cell.global_position-Global.TILE_SIZE/2, Global.TILE_SIZE).has_point(event.position):
				target = Global.position_normilize(cell.global_position)
				Global.busy_cells.remove_at(Global.busy_cells.find(position))
				Global.busy_cells.append(target)
				move_cells.visible = false
		move_cells.visible = entity_click

func _move_changed():
	for child in move_cells.get_children():
		child.queue_free()
	
	for dir in controller.MOVE_RANGE:
		var length = controller.MOVE_RANGE[dir]
		for i in range(1, length+1):
			var new_pos = Global.position_normilize(-Global.TILE_SIZE/2 + position + Global.TILE_SIZE*dir*i)
			if new_pos in Global.busy_cells or !Global.MAP_RECT.has_point(new_pos):
				break
			new_move_cell(Global.TILE_SIZE * dir*i)

func new_move_cell(pos :Vector2):
	var cell = Global.MOVE_CELL.duplicate().instantiate()
	cell.position = (Global.POS_DELTA + pos) / scale
	cell.scale = Global.TILE_SIZE / cell.sprite_frames.get_frame_texture("default", 0).get_size() / scale
	move_cells.add_child(cell)

func get_info() -> String:
	return "Name: %s\nLevel: %s %s\nHits: %s/%s\n" % \
	  [display_name, str(level), get_exp_info(), str(hits), str(max_hits)]\
	  + controller.get_unique_info()

func get_exp_info() -> String:
	if type == "elf":
		return ""
	if level == 5:
		return "(MAX)"
	if exp < Global.LEVEL_EXP[level]:
		return "(%s/%s)" % [exp, Global.LEVEL_EXP[level]]
	return "(UP: %s crowns)" % Global.ENTITY_PARAM[full_id]["level%s" % str(level+1)]["cost"]

func change_hits(value :float):
	hits += ceil(randf()*value*100)/100.0
	if hits <= 0:
		kill()
	if hits > max_hits:
		hits = max_hits
	
	stun_cooldown += 1
	allow_move = false
	texture.play("idle")

func levelup():
	var info = Global.ENTITY_PARAM[full_id]["level%s" % str(level+1)]
	level += 1
	max_hits = info["hits"]
	hits = info["hits"]
	skill_cooldown = Global.timer+info["cooldown"]

func kill():
	print("[INFO] Killing entity (%s)" % node_name)
	
	Global.busy_cells.remove_at(Global.busy_cells.find(position))
	get_parent().remove_child(self)
	set_physics_process(false)
	queue_free()

