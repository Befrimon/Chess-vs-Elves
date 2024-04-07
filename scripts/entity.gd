class_name Entity 
extends CharacterBody2D

## Variables
var texture : AnimatedSprite2D
var hpbar : Sprite2D
var audio : AudioStreamPlayer2D
var size : Vector2
var controller : Node
var type : String

## Init function
func init(sname: String, pos: Vector2):
	## Set variables
	texture = get_node("Texture")
	hpbar = get_node("HPbar")
	audio = get_node("Audio")
	type = sname
	
	## Configure texture
	texture.sprite_frames = load("res://animations/%s.tres" % sname)
	var orig_size = texture.sprite_frames.get_frame_texture("idle", 0).get_size()
	texture.scale *= 90 / orig_size.x
	
	## Set position
	position = pos

func set_controller(contr: Node):
	controller = contr

## Remove object from scene
func kill():
	EntityController.controller_group.remove_child(controller)
	controller.queue_free()
	get_parent().remove_child(self)
	self.queue_free()
	print("Killed ", name)
	self.set_physics_process(false)

