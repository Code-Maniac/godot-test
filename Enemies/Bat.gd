extends KinematicBody2D

const MAX_WANDER_SPEED = 20.0
const WANDER_ACCELERATION = 30


const MAX_CHASE_SPEED = 300.0
const CHASE_ACCELERATION = 100.0

const KNOCKBACK_SPEED = 200.0
const KNOCKBACK_DECCELERATION = 500.0

const MIN_IDLE_WAIT:float = 0.5
const MAX_IDLE_WAIT:float = 2.0

const MIN_WANDER_DIST:float = 15.0
const MAX_WANDER_DIST:float = 30.0

const CHASE_DISTANCE:float = 100.0

onready var animPlayer = $AnimationPlayer
onready var animTree = $AnimationTree
onready var animState = $AnimationTree.get("parameters/playback")
onready var stats = $Stats

onready var hurtbox_shape = $Hurtbox/CollisionShape2D
onready var player = get_parent().get_node("Player")

# tether the bat it's start position
# when calculating a new wander direction
# if the bat is too far from the tether then move back towards the tether.
onready var tether = self.global_position

enum { IDLE, WANDER, CHASE }
onready var state = IDLE

# various state vars
onready var idle_timer = $IdleTimer
onready var wander_dir = Vector2.ZERO
onready var wander_dist = 0.0

onready var velocity = Vector2.ZERO

func _ready():
	_enter_idle_state()
	pass # Replace with function body.

func _process(delta):
	match state:
		IDLE:
			_state_idle(delta)
		WANDER:
			_state_wander(delta)
		CHASE:
			_state_chase(delta)



func _on_Hurtbox_area_entered(area:Area2D):
	# get a vector from area to our center and use that to calculate the
	# knockback direction
	# var hit_dir = (self.position - area.player_position).normalized()

	# # play a sound for the hit

	# velocity = hit_dir * KNOCKBACK_SPEED
	# # state = KNOCKBACK

	# stats.health -= area.damage
	pass


func _enter_idle_state():
	idle_timer.start(rand_range(MIN_IDLE_WAIT, MAX_IDLE_WAIT))
	state = IDLE


func _enter_wander_state():
	wander_dir = Vector2(-0.5 + randf(), -0.5 + randf()).normalized()
	wander_dist =  rand_range(MIN_WANDER_DIST, MAX_WANDER_DIST)
	state = WANDER


func _check_player_dist():
	return false
	# check if the player is within the threshold distance for chasing
	# if yes then enter the chase state and return true
	# otherwise return false
	var self_to_player = self.global_position - player.global_position

	var output = false
	if self_to_player.length() < CHASE_DISTANCE:
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

	print(idle_timer.time_left)
	if idle_timer.time_left == 0:
		print("Elapsed")
		_enter_wander_state()

func _state_wander(delta):
	# move to the picked position
	if _check_player_dist():
		pass

	var current_pos = self.global_position

	velocity = velocity.move_toward(wander_dir * MAX_WANDER_SPEED, WANDER_ACCELERATION * delta)
	velocity = move_and_slide(velocity)

	# subtract the distasnce moved from the total distance that will be
	# wandered
	# if < 0 then move to idle state
	var dist_moved = (current_pos - self.global_position).length()
	wander_dist -= dist_moved
	if wander_dist < 0:
		_enter_idle_state()

func _state_chase(delta):
	if not _check_player_dist():
		pass

	# get direction to player and accelerate towards the player
	# don't exceed the max chase speed
	var dir = (player.global_position - self.global_position).normalized()
	velocity = velocity.move_toward(dir * MAX_CHASE_SPEED, CHASE_ACCELERATION * delta)
	velocity = move_and_slide(velocity)
