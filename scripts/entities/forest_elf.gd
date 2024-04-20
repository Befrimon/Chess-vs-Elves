class_name ForestElf extends Entity

var skill_target :Entity

func _init(pos :Vector2, index :int) -> void:
	# load data from configs
	name = "forest_elf-%s" % index
	data = JSON.parse_string(FileAccess.get_file_as_string("res://sources/entities/forest_elf.json"))
	
	super(pos, index)  # Parent init
	
	texture.flip_h = true
	
	type = Type.ELF
	iname = Name.FOREST_ELF
	speed = 70
	target = Vector2(0, position.y)

func get_info() -> String:
	return "Название: %s\nХиты: %s/%s\nУрон: %s"\
	% [data["name"], data["level%s"%level]["hits"]-int(damage*100)/100.0, 
	data["level%s"%level]["hits"], data["level%s"%level]["attack"]]

func skill() -> void:
	if skill_target != null and is_instance_valid(skill_target) and skill_target.type == Type.FIGURE:
		skill_cooldown += data["level%s" % level]["cooldown"]
		skill_target.change_hits(data["level%s" % level]["attack"] + bonus_value, self)
		skill_target.allow_move = false
		skill_target.stun_time = 1
		return
	elif skill_target != null and is_instance_valid(skill_target) and skill_target.type == Type.ELF:
		skill_target.bonus_value = data["level%s" % level]["attack"] / 2
		return 
	
	for entity in skillbox.get_overlapping_bodies():
		if entity != self:
			skill_target = entity
			break
