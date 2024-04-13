extends Sprite2D
class_name Preview

var figure :String


func _init():
	visible = false

func set_figure(ename :String):
	figure = ename

func set_new(pos :Vector2):
	visible = true
	texture = load("res://textures/previews/%s.png" % figure)
	position = pos
	scale = Global.TILE_SIZE / texture.get_size().x

func clear():
	visible = false
