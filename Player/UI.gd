extends Control

var hearts = 6 setget set_hearts
var max_hearts = 6 setget set_max_hearts

onready var uiheart_empty = $UIHeartEmpty
onready var uiheart_full = $UIHeartFull


# Called when the node enters the scene tree for the first time.
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_hearts(val):
	hearts = clamp(val, 0, max_hearts)
	if uiheart_full != null:
		uiheart_full.rect_size.x = hearts * 15

func set_max_hearts(val):
	max_hearts = max(val, 1)
	if uiheart_empty != null:
		uiheart_empty.rect_size.x = max_hearts * 15
