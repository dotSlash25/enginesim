extends Sprite2D

func _ready() -> void:
	render_stack()

func rotate_sprite(rotDel):
	for child in get_children():
		child.rotate(rotDel)

func set_sprite_rotation(rot):
	for child in get_children():
		child.rotation = rot

func render_stack():
	for i in range(hframes):
		var s = Sprite2D.new()
		s.texture = texture
		s.hframes = hframes
		s.frame = i
		s.position.y = -i
		add_child(s)
