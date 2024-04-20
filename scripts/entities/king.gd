class_name King extends Entity

func _init(pos :Vector2, index :int) -> void:
	name = "king-%s" % index
	data = JSON.parse_string(FileAccess.get_file_as_string("res://sources/entities/king.json"))
	
	super(pos, index)
	
	# Configure node
	type = Type.FIGURE
	iname = Name.KING
	speed = 500

func get_info() -> String:
	return "Название: %s\nУровень: %s (%s/%s)\nХиты: %s/%s\nКорон: %s (%s сек)\n%s"\
	% [data["name"], level, exp, Global.config["levels"][level], 
		data["level%s"%level]["hits"]-int(damage*100)/100.0, data["level%s"%level]["hits"], 
		data["level%s"%level]["crown"], int(skill_cooldown),
			"Улучшить: %s корон" % data["level%s"%(level+1)]["cost"] \
			if exp == Global.config["levels"][level] else ""]

func skill() -> void:
	skill_cooldown += data["level%s" % level]["cooldown"]
	get_node("/root/Game").crown_count += data["level%s" % level]["crown"] + bonus_value
	if exp != Global.config["levels"][level]:
		exp += 10
