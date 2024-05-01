extends Node2D

enum Chapter {FIGURES, ELVES}

var pages :Dictionary = {
	Chapter.FIGURES: ["rook", "king", "pawn", "bishop", "knight", "queen"],
	Chapter.ELVES: ["forest_elf", "dark_elf"]
}
var entities :Array[Entity] = [Rook.new(Vector2.ZERO, 0), Pawn.new(Vector2.ZERO, 0), King.new(Vector2.ZERO, 0), Bishop.new(Vector2.ZERO, 0), Knight.new(Vector2.ZERO, 0), Queen.new(Vector2.ZERO, 0)]

var cur_page :int = 0
var cur_chapter :Chapter = Chapter.FIGURES

# Child nodes
var title :Label
var main_description :RichTextLabel
var top_small_description :Label
var bottom_small_description :Label
var help_image :TextureRect

func _ready() -> void:
	title = get_node("GUI/Title")
	main_description = get_node("GUI/BigTextBlock")
	top_small_description = get_node("GUI/SideTextBlock")
	bottom_small_description = get_node("GUI/SideTextBlock2")
	help_image = get_node("GUI/HelpImage")
	
	get_node("GUI/ButtonLeft").pressed.connect(change_page.bind(-1))
	get_node("GUI/ButtonRight").pressed.connect(change_page.bind(1))
	
	get_node("GUI/CloseButton").pressed.connect(close_help)
	
	change_page(0)

func change_page(delta :int) -> void:
	if (delta == -1 and cur_page == 0) or (delta == 1 and cur_page == len(pages[cur_chapter])-1):
		return
	cur_page += delta
	
	var data = JSON.parse_string(FileAccess.get_file_as_string(
		"res://sources/entities/%s.json" % pages[cur_chapter][cur_page]))
	title.text = data["name"]
	help_image.texture = load("res://textures/helpbook/entity/%s.png" % pages[cur_chapter][cur_page])
	main_description.text = data["description"]# + "\n\n" + entities[cur_page].get_info()

func close_help() -> void:
	visible = false
	get_tree().paused = false
