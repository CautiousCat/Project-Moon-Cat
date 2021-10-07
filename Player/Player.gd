extends KinematicBody2D

onready var floor_detection = $Overlaps/Floor
onready var left_wall_detection = $Overlaps/LeftWall
onready var right_wall_detection = $Overlaps/RightWall
onready var anim_sprite = $AnimationPlayer
onready var sprite = $Sprite

export var MAX_SPEED = 50
export var ACCELERATION = 1000
export var FRICTION = 1000
export var JUMP_SPEED = 200
export var GRAVITY = 500
export var TERMINAL_FALLSPEED = 200
export var WALLSLIDE_SPEED = 125
export var WALLSLIDE_ACCELERATION = 200

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var jumped = false
var is_moving = false

enum {NORMAL, WALLCLING}

var state = NORMAL

func _physics_process(delta):
	is_moving = getInput()
	match (state):
		NORMAL:
			jumpAndGravity(delta)
			horizontalMovement(delta)
			if not floor_detection.is_colliding() and (left_wall_detection.is_colliding() or right_wall_detection.is_colliding()):
				state = WALLCLING
		WALLCLING:
			walljumpAndGravity(delta)
			horizontalMovement(delta)
			if floor_detection.is_colliding() or (not left_wall_detection.is_colliding() and not right_wall_detection.is_colliding()):
				state = NORMAL
	animation()
	move_and_slide(velocity)
	
func getInput():
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	jumped = Input.is_action_just_pressed("ui_up")
	
	return direction != Vector2.ZERO 

func animation():
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
		
	if velocity.y < 0:
		anim_sprite.play("JUMP")
	elif velocity.y > 0:
		anim_sprite.play("FALL")
		
	if is_moving and floor_detection.is_colliding():
		anim_sprite.play("WALK")
	elif floor_detection.is_colliding():
		anim_sprite.play("IDLE")
		
	if state == WALLCLING:
		 anim_sprite.play("WALLCLING")

func horizontalMovement(delta):
	if is_moving:
		velocity = velocity.move_toward(Vector2(direction.x * MAX_SPEED, velocity.y), ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2(0, velocity.y), FRICTION * delta)

func jumpAndGravity(delta):
	if floor_detection.is_colliding() and jumped: 
		velocity.y -= JUMP_SPEED
	elif floor_detection.is_colliding():
		velocity.y = 0
	else:
		if velocity.y > 0:
			velocity.y += GRAVITY * delta * 1.8
		else:
			velocity.y += GRAVITY * delta
	
	if velocity.y > TERMINAL_FALLSPEED:
		velocity.y = TERMINAL_FALLSPEED

func walljumpAndGravity(delta):
	if left_wall_detection.is_colliding():
		if not is_moving:
			if velocity.y < 0:
				velocity.y += GRAVITY * delta
			else:
				velocity.y += GRAVITY * delta
		else:
			if direction.x < 0:
				if velocity.y > 0:
					velocity = velocity.move_toward(Vector2(velocity.x, WALLSLIDE_SPEED), WALLSLIDE_ACCELERATION * delta)
				if velocity.y < 0:
					velocity = velocity.move_toward(Vector2(velocity.x, WALLSLIDE_SPEED), GRAVITY * delta)
		if jumped:
			velocity.y = -JUMP_SPEED 
			velocity.x = MAX_SPEED * 1.5
	elif right_wall_detection.is_colliding():
		if not is_moving:
			if velocity.y < 0:
				velocity.y += GRAVITY * delta
			else:
				velocity.y += GRAVITY * delta 
		else: 
			if direction.x > 0:
				if velocity.y > 0:
					velocity = velocity.move_toward(Vector2(velocity.x, WALLSLIDE_SPEED), WALLSLIDE_ACCELERATION * delta)
				if velocity.y < 0:
					velocity = velocity.move_toward(Vector2(velocity.x, WALLSLIDE_SPEED), GRAVITY * delta )
		if jumped:
			velocity.y = -JUMP_SPEED 
			velocity.x = -MAX_SPEED * 1.5
		
	if velocity.y > WALLSLIDE_SPEED:
		velocity.y = WALLSLIDE_SPEED
