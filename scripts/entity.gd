class_name Entity 
extends CharacterBody2D

## Variables
var texture : AnimatedSprite2D
var selector : AnimatedSprite2D
var hpbar : Sprite2D
var audio : AudioStreamPlayer2D
var size : Vector2
var controller : Node
var dname : String
var bid : String

## Init function
func init(sname: String, id: String, pos: Vector2):
	## Set variables
	texture = get_node("Texture")
	selector = get_node("Selector")
	hpbar = get_node("HPbar")
	audio = get_node("Audio")
	dname = sname
	bid = id 
	
	## Configure texture
	texture.sprite_frames = load("res://animations/%s.tres" % bid)
	var orig_size = texture.sprite_frames.get_frame_texture("idle", 0).get_size()
	texture.scale *= EntityController.TILE_SIZE / orig_size.x
	
	## Set position
	position = pos

func _input(event):
	if event is InputEventMouseButton:
		var pos = event.position
		var delta = EntityController.TILE_SIZE / 2
		if !Preview.enabled and position.x - delta <= pos.x and pos.x <= position.x + delta and \
			position.y - delta <= pos.y and pos.y <= position.y + delta:
			selector.visible = true
			Global.game_ui.change_info(self)
		else:
			selector.visible = false

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

