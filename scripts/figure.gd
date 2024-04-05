extends Node2D

var texture : AnimatedSprite2D
var body : RigidBody2D
var size : Vector2

func _ready():
	texture = get_node("Texture")
	body = get_node("Body")
	size = texture.sprite_frames.get_frame_texture("pawn", 0).get_size() * scale.x


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() \
		and (event is InputEventMouseButton or event is InputEventScreenTouch):
		var pos = position - size / 2.0
		if Rect2(pos, size).has_point(event.position):
			print("click!")
