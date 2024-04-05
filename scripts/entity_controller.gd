extends Node

const FIGURE = preload("res://prefabs/figure.tscn")
const ELF = preload("res://prefabs/elf.tscn")


func new_figure(parent: Node2D, name: String, pos: Vector2):
	print("Creating new %s" % name)
	
	var fig = FIGURE.instantiate()
	fig.get_node("Texture").animation = name
	fig.position = pos
	parent.add_child(fig)

func new_elf(parent: Node2D, name: String = "base"):
	print("Creating new %s elf" % name)
	
	var elf = ELF.instantiate()
	elf.position = Vector2(1660, 310 + 80*randi_range(0, 6))
	print(elf.position)
