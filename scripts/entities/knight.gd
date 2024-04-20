class_name Knight extends Entity

var skill_target :Entity

func _init(pos :Vector2, index :int) -> void:
	name = "knight-%s" % index
	data = JSON.parse_string(FileAccess.get_file_as_string("res://sources/entities/knight.json"))
	
	super(pos, index)
	
	# Configure node
	type = Type.FIGURE
	iname = Name.KNIGHT
	speed = 500

func get_info() -> String:
	return "Название: %s\nУровень: %s (%s/%s)\nХиты: %s/%s\nУрон: %s\n%s"\
	% [data["name"], level, exp, Global.config["levels"][level], 
		data["level%s"%level]["hits"]-int(damage*100)/100.0, data["level%s"%level]["hits"], 
		data["level%s"%level]["attack"], "Улучшить: %s корон" % data["level%s"%(level+1)]["cost"] \
			if exp == Global.config["levels"][level] else ""]

func skill() -> void:
	if skill_target != null and is_instance_valid(skill_target):
		skill_cooldown += data["level%s" % level]["cooldown"]
		skill_target.change_hits(data["level%s" % level]["attack"] + bonus_value, self)
		skill_target.allow_move = false
		skill_target.stun_time = 1
		if skill_target.damage == -1 and exp != Global.config["levels"][level]:
			exp += 25
		return
	
	for entity in skillbox.get_overlapping_bodies():
		if entity.type == Type.ELF:
			skill_target = entity
			break
