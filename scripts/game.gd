extends Node2D

const FIGURE = preload("res://prefabs/figure.tscn")


func test_figure_gen():
	for x in range(342, 440, 93):
		for y in range(50, 710, 93):
			var cur_fig = FIGURE.duplicate().instantiate()
			cur_fig.position.x = x
			cur_fig.position.y = y
			add_child(cur_fig)


func _ready():
	if Global.game_state == "New":
		test_figure_gen()
	

