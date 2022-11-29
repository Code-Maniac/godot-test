extends Area2D

signal hit(damage)

export(bool) var show_hit = true
export(float) var invinsibility_time

const hit_effect_preload = preload("res://Effects/HitEffect.tscn")
onready var invinsibility_timer = $InvinsibilityTimer

var invinsible = false setget set_invinsible

func _ready():
	invinsibility_timer.wait_time = invinsibility_time

func _on_Hurtbox_area_entered(area:Area2D):
	if not invinsible:
		if show_hit:
			var hit_effect = hit_effect_preload.instance()
			get_parent().add_child(hit_effect)
			hit_effect.global_position = global_position

		emit_signal("hit", area.damage)
		invinsible = true

func _on_InvinsibilityTimer_timeout():
	# invinsibility has ended
	invinsible = false

func set_invinsible(val:bool):
	invinsible = val
	if val:
		invinsibility_timer.stop()
		# invinsibility_timer.remaining_time


