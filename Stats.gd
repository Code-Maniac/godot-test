extends Node

# max health defaults to 1
export(int) var max_health = 1

# healths starts at max_health
onready var health = max_health

func _ready():
	pass