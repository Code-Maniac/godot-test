extends Area2D

export(bool) var show_hit = true

const hit_effect_preload = preload("res://Effects/HitEffect.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Hurtbox_area_entered(_area:Area2D):
	if show_hit:
		var hit_effect = hit_effect_preload.instance()
		var main = get_tree().current_scene
		main.add_child(hit_effect)
		hit_effect.global_position = global_position

