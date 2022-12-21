extends KinematicBody2D

const MAX_WANDER_SPEED = 20.0
const WANDER_ACCELERATION = 30

const MAX_CHASE_SPEED = 80.0
const CHASE_ACCELERATION = 80.0

const KNOCKBACK_SPEED = 90.0
const KNOCKBACK_DECCELERATION = 500.0

const MIN_IDLE_WAIT:float = 0.5
const MAX_IDLE_WAIT:float = 2.0

const MIN_WANDER_DIST:float = 15.0
const MAX_WANDER_DIST:float = 30.0

const CHASE_DISTANCE:float = 100.0

const MAX_DISTANCE_FROM_TETHER:float = 100.0

onready var animPlayer = $AnimationPlayer
onready var animTree = $AnimationTree
onready var animState = $AnimationTree.get("parameters/playback")
onready var stats = $Stats

onready var hurtbox_shape = $Hurtbox/CollisionShape2D
var player = null

const death_effect_preload = preload("res://Effects/EnemyDeathEffect.tscn")

# tether the bat it's start position
# when calculating a new wander direction
# if the bat is too far from the tether then move back towards the tether.
onready var tether_pos = self.global_position

enum { IDLE, WANDER, TETHER, CHASE }
onready var state = IDLE

# various state vars
onready var idle_timer = $IdleTimer

onready var velocity = Vector2.ZERO

# the path that the bat is going to take based on either the current player
# position or the tether position
var path: Array = []
var nav = null
var nav_threshold = 3.0
onready var path_dir = self.global_position
onready var nav_line = $Line2D

func _ready():
	# get the level navigation and the player
	yield(get_tree(), "idle_frame")
	var tree = get_tree()

	if tree.has_group("LevelNavigation"):
		nav = tree.get_nodes_in_group("LevelNavigation")[0]

	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

	_enter_idle_state()


func _process(delta):
	nav_line.points = path
	nav_line.global_position = Vector2.ZERO
	match state:
		IDLE:
			_state_idle(delta)
		WANDER:
			_state_wander(delta)
		CHASE:
			_state_chase(delta)


func _enter_idle_state():
	idle_timer.start(rand_range(MIN_IDLE_WAIT, MAX_IDLE_WAIT))
	state = IDLE


func _enter_wander_state():
	# if we are too far away from the tether then walk back to the tether
	# otherwise random wander
	if global_position.distance_to(tether_pos) > MAX_DISTANCE_FROM_TETHER:
		_enter_wander_state_tether()
	else:
		_enter_wander_state_random()


func _enter_wander_state_random():
	var dir = Vector2(-0.5 + randf(), -0.5 + randf()).normalized()
	var dist =  rand_range(MIN_WANDER_DIST, MAX_WANDER_DIST)
	path = _get_path_to(global_position + (dir * dist));

	state = WANDER


func _enter_wander_state_tether():
	path = _get_path_to(tether_pos)
	state = WANDER


func _check_player_dist():
	# check if the player is within the threshold distance for chasing
	# if yes then enter the chase state and return true
	# otherwise return false
	var player_dist = global_position.distance_to(player.global_position)

	var output = false
	if player_dist < CHASE_DISTANCE:
		state = CHASE
		output = true
	elif state == CHASE:
		_enter_wander_state()

	return output


func _state_idle(_delta):
	# wait a random time between 0.5 and 2 seconds
	# then:
	# 1. pick random direction
	# 2. pick random dictance between 20 and 100
	# enter wander state
	if _check_player_dist():
		pass

	if idle_timer.time_left == 0:
		_enter_wander_state()


func _state_wander(delta):
	# move to the picked position
	if _check_player_dist():
		pass
	elif path.size() <= 1:
		_enter_idle_state()
		pass
	else:
		_navigate()
		velocity = velocity.move_toward(path_dir * MAX_WANDER_SPEED, WANDER_ACCELERATION * delta)
		_move()


func _state_chase(delta):
	if not _check_player_dist():
		pass

	# while chasing the player we need to keep generating the path as the player
	# most likely will have moved from the original position when we entered
	# the chase state
	path = _get_path_to(player.global_position)
	_navigate()
	velocity = velocity.move_toward(path_dir * MAX_CHASE_SPEED, CHASE_ACCELERATION * delta)
	_move()


func _get_path_to(pos):
	var output = []
	if nav != null:
		output = nav.get_simple_path(global_position, pos, false)

	return output


func _navigate():
	if path.size() > 1:
		path_dir = global_position.direction_to(path[1])

		if global_position.distance_to(path[1]) < nav_threshold:
			path.pop_front()


func _move():
	velocity = move_and_slide(velocity)



func _on_Hurtbox_hit(damage):
	velocity = KNOCKBACK_SPEED * player.global_position.direction_to(global_position)
	stats.health -= damage


func _on_Stats_health_depleted():
	# health goes to zero or less then death
	var death_effect = death_effect_preload.instance()
	get_parent().add_child(death_effect)
	death_effect.global_position = hurtbox_shape.global_position
	queue_free()
