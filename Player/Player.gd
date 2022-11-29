extends KinematicBody2D

const MAX_SPEED = 80
const ACCELERATION = 300
const FRICTION = 500

const ROLL_SPEED = MAX_SPEED * 1.5

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var state_after_roll = MOVE
var velocity = Vector2.ZERO

onready var animPlayer = $AnimationPlayer
onready var animTree = $AnimationTree
onready var animState = $AnimationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox

onready var stats = $Stats

func _read():
	animTree.active = true

func _process(delta):
	match state:
		MOVE:
			do_move(delta)
		ROLL:
			do_roll(delta)
		ATTACK:
			do_attack(delta)


func do_move(delta):
	# calculate the direction in which the player is moving based on which
	# arrow buttons are pressed
	# then multiply this normalized value by the speed and the delta
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		animTree.set("parameters/Idle/blend_position", input_vector)
		animTree.set("parameters/Run/blend_position", input_vector)
		animTree.set("parameters/Attack/blend_position", input_vector)
		animState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity = velocity.limit_length(MAX_SPEED)
	_move()



	if Input.is_action_just_pressed("attack"):
		state = ATTACK

	if Input.is_action_just_pressed("roll") and input_vector != Vector2.ZERO:
		state = ROLL
		animTree.set("parameters/Roll/blend_position", velocity)
		velocity = velocity.normalized() * ROLL_SPEED


func do_roll(_delta):
	_move()
	animState.travel("Roll")

	if Input.is_action_just_pressed("attack"):
		state_after_roll = ATTACK


func do_attack(_delta):
	# do an attack. When the animation is finished
	velocity = Vector2.ZERO
	animState.travel("Attack")

	# set the player position on the sword hitbox
	swordHitbox.player_position = position


func attack_anim_finished():
	state = MOVE
	animState.travel("Idle")


func roll_anim_finished():
	state = state_after_roll
	if state == MOVE:
		animState.travel("Idle")
	else:
		animTree.set("parameters/Attack/blend_position", velocity)

	state_after_roll = MOVE # reset out variable


func _move():
	velocity = move_and_slide(velocity)

func _set_blend_position(vec):
	var bps = [
		"parameters/Idle/blend_position",
		"parameters/Run/blend_position",
		"parameters/Attack/blend_position",
	]
	for bp in bps:
		animTree.set(bp, vec)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
	
	# pass


func _on_Hurtbox_hit(damage):
	stats.health -= damage
	# should probably add some sort of invisibility frames
	stats.
