extends AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	frame = 0
	play("Animate")
	connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")

func _on_AnimatedSprite_animation_finished():
	# delete self when the animation finished
	queue_free()
