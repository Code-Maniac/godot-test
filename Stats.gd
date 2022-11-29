extends Node

# max health defaults to 1
export(int) var max_health = 1

# healths starts at max_health
onready var health = max_health setget set_health

signal health_depleted

func _ready():
	pass

func set_health(value):
	health = value
	if health <= 0:
		emit_signal("health_depleted")