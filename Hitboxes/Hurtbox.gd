extends Area2D

signal hit(damage)

export(bool) var show_hit = true

const hit_effect_preload = preload("res://Effects/HitEffect.tscn")
onready var invincibility_timer = $InvincibilityTimer

var invincible = false setget set_invincible
signal invicibility_start
signal invincibility_end

func _on_Hurtbox_area_entered(area:Area2D):
	if not self.invincible:
		if show_hit:
			var hit_effect = hit_effect_preload.instance()
			get_parent().add_child(hit_effect)
			hit_effect.global_position = global_position

		emit_signal("hit", area.damage)

func start_invincibility(time):
	self.invincible = true
	invincibility_timer.wait_time = time
	invincibility_timer.start()

func _on_InvincibilityTimer_timeout():
	# invincibility has ended
	self.invincible = false

func set_invincible(val:bool):
	invincible = val
	if invincible:
		emit_signal("invicibility_start")
	else:
		emit_signal("invincibility_end")


func _on_Hurtbox_invicibility_start():
	set_deferred("monitorable", false)


func _on_Hurtbox_invincibility_end():
	set_deferred("monitorable", true)
