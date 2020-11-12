extends KinematicBody2D

enum { DIE, FALL, JUMP, LAND, NORMAL }
const GRAVITY := 800
const JUMP_VELOCITY := -200
const AIR_JUMP_MULT := 0.75
const MIN_FALL_JUMP_TIME := 0.30

onready var velocity := Vector2.ZERO

export var speed := 65
export var air_control := true
export var max_air_jumps := 1

var state := NORMAL
var air_jumps := 0 
var last_y := 0.0
var fall_time := 0.0

func _ready():
	# Allows the 1st call to is_on_floor() to work correctly 
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP, true)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	match state:
		DIE:
			pass
		FALL:
			if is_on_floor():
				state = LAND
			elif fall_time <= MIN_FALL_JUMP_TIME:
				air_jumps = max_air_jumps
				jump()
			
			fall_time += delta
		JUMP:
			jump()
			pass
		LAND:
#			print("fell: %f" % (global_position.y - last_y))
#			So if only our dust timer is finished
#			We are going to emit a particle
			if $DustTimer.is_stopped():
				$FootDust.emitting = true
#				We want the dust timer
#				We want to start it
				$DustTimer.start($FootDust.lifetime + 0.2)  				
			fall_time = 0
			state = NORMAL
			pass
		NORMAL:
			if !is_on_floor():
				state = FALL
				last_y = global_position.y
			else:				
				horizontal()
				
				if Input.is_action_just_pressed("Jump"):
					air_jumps = max_air_jumps
					state = JUMP
					jump()

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP, true)

func horizontal():
	if Input.is_action_pressed("Left"):
		velocity.x = -speed
		$Sprite.flip_h = true
	elif Input.is_action_pressed("Right"):
		velocity.x = speed
		$Sprite.flip_h = false
	else: 
		velocity.x = 0
		
	if is_on_floor():
		if velocity.x == 0:
			$Animation.play("Idle")
		else:
			$Animation.play("Walk")

func jump():
	if air_control:
		horizontal()
		
#	We have one jump and that would be just on the floor
	if Input.is_action_just_pressed("Jump") and air_jumps >= 0:
		$Animation.play("Jump")
		state = JUMP
		
#		We want to check if this is the first jump
#		If we just now jumped that must mean we're on the floor
		if air_jumps == max_air_jumps:
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY * AIR_JUMP_MULT
			
		air_jumps -= 1
		
#		What we'll do is anytime we jump we'll set last_y 
#		equal to the global y position of the character
#		That will let us see how far we have fallen 
		last_y = global_position.y
		
#	If the jump key wasn't pressed of if we don't have any jumps
#	We want to check our velocity is greater than or equal to zero 
#	to make sure that we're actually falling or have fallen
	elif is_on_floor() and velocity.y >= 0:
		state = LAND
