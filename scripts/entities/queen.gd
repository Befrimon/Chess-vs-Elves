class_name Queen extends Entity

func _init(pos :Vector2, index :int) -> void:
	name = "queen-%s" % index
	data = JSON.parse_string(FileAccess.get_file_as_string("res://sources/entities/queen.json"))
	
	super(pos, index)
	
	# Configure node
	type = Type.FIGURE
	iname = Name.KING
	speed = 500

func get_info() -> String:
	return "Название: %s\nУровень: %s (%s/%s)\nХиты: %s/%s\nБонус: %s атк /%s кор\n%s"\
	% [data["name"], level, exp, Global.config["levels"][level], 
		data["level%s"%level]["hits"]-int(damage*100)/100.0, data["level%s"%level]["hits"], 
		data["level%s"%level]["attack"], data["level%s"%level]["crown"],
			"Улучшить: %s корон" % data["level%s"%(level+1)]["cost"] \
			if exp == Global.config["levels"][level] else ""]

func skill() -> void:
	for entity in skillbox.get_overlapping_bodies():
		if entity.type == Type.FIGURE and entity.iname == Name.KING:
			entity.bonus_value += data["level%s"%level]["crown"]
		elif entity.type == Type.FIGURE:
			entity.bonus_value += data["level%s"%level]["attack"]
