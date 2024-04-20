class_name Bishop extends Entity


func _init(pos :Vector2, index :int) -> void:
	name = "bishop-%s" % index
	data = JSON.parse_string(FileAccess.get_file_as_string("res://sources/entities/bishop.json"))
	
	super(pos, index)
	
	# Configure node
	type = Type.FIGURE
	iname = Name.BISHOP
	speed = 500

func get_info() -> String:
	return "Название: %s\nУровень: %s (%s/%s)\nХиты: %s/%s\nЛечение: %s (%s сек)\n%s"\
	% [data["name"], level, exp, Global.config["levels"][level], 
		data["level%s"%level]["hits"]-int(damage*100)/100.0, data["level%s"%level]["hits"], 
		data["level%s"%level]["heal"], int(skill_cooldown),
			"Улучшить: %s корон" % data["level%s"%(level+1)]["cost"] \
			if exp == Global.config["levels"][level] else ""]

func skill() -> void:
	var skill_target :Entity = null
	
	for entity in skillbox.get_overlapping_bodies():
		if entity.type == Type.FIGURE and ((skill_target == null or skill_target.damage > entity.damage) and entity.damage != 0):
			skill_target = entity
	
	if skill_target != null and is_instance_valid(skill_target):
		skill_cooldown += data["level%s" % level]["cooldown"]
		skill_target.change_hits(-1*(data["level%s" % level]["heal"] + bonus_value), self)
		exp += 25
		return
	
	
