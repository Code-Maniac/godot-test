extends Node

# max health defaults to 6
export(int) var max_health = 6 setget set_max_health

# healths starts at max_health
onready var health = max_health setget set_health

signal health_depleted
signal health_changed
signal max_health_changed

func _ready():
	pass

func set_health(value):
	if value != health:
		health = value
		emit_signal("health_changed", health)
		if health <= 0:
			emit_signal("health_depleted")

func set_max_health(value):
	if value != max_health:
		max_health = value
		emit_signal("max_health_changed", max_health)