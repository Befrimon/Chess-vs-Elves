extends Node2D

const pages :Array = [
	"", "rook_defender", "pawn_figure", "king_figure", "bishop_figure", 
	"knight_figure", "queen_figure"
	]
var page :int = 0

var title :Label
var description_left :RichTextLabel
var description_right :RichTextLabel
var image_description :TextureRect

var descriptions = JSON.parse_string(FileAccess.get_file_as_string("res://sources/dictionary.json"))

func _ready():
	title = get_node("Control/Title")
	description_left = get_node("Control/Desctiption")
	description_right = get_node("Control/Desctiption2")
	image_description = get_node("Control/ImageDescription")
	
	get_node("Control/ButtonLeft").pressed.connect(change_page.bind(-1))
	get_node("Control/ButtonRight").pressed.connect(change_page.bind(1))
	get_node("Control/CloseButton").pressed.connect(close)
	
	change_page(0)

func close():
	get_tree().paused = false
	visible = false

func change_page(delta :int):
	page += delta
	if page < 0 or page >= len(pages):
		page -= delta
		return
	elif page == 0:
		title.text = "Термины"
		description_left.text = descriptions["zero"][0]
		description_right.text = descriptions["zero"][1]
		image_description.texture = null
		return
	
	var figure_info = Global.ENTITY_PARAM[pages[page]]
	title.text = figure_info["name"]
	var raw_text = "%s\n\n[b]Характеристики на 1 ур[/b]\nХиты: %s\n" %\
		[figure_info["description"], figure_info["level1"]["hits"]]
	match pages[page]:
		"rook_defender":
			raw_text += "Кричит THE ROOOOK!!!"
		"pawn_figure", "knight_figure":
			raw_text += "Урон: %s ед" % str(-1*figure_info["level1"]["value"])
		"king_figure":
			raw_text += "Короны: %s\nОткат: %s сек" % \
				[figure_info["level1"]["value"], figure_info["level1"]["cooldown"]]
		"bishop_figure":
			raw_text += "Лечение: %s ед\nОткат: %s сек" % \
				[figure_info["level1"]["value"], figure_info["level1"]["cooldown"]]
		"queen_figure":
			raw_text += "Лечение/урон: %s\nКороны: %s" % figure_info["level1"]["value"]
	description_left.text = raw_text
	description_right.text = descriptions[pages[page]]
	image_description.texture = load("res://textures/helpbook/%s.png" % pages[page])

