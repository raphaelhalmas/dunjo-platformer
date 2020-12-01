extends KinematicBody2D

const InteractType = preload("res://Commons/GlobalEnums.gd").InteractType
const PlayerState = preload("res://Commons/GlobalEnums.gd").PlayerState

const GRAVITY := 800
const JUMP_VELOCITY := -200
const AIR_JUMP_MULT := 0.75
const MIN_FALL_JUMP_TIME := 0.30

onready var velocity := Vector2.ZERO

export var speed := 65
export var air_control := true
export var max_air_jumps := 1

var state: int = PlayerState.NORMAL
var prev_state: int = PlayerState.NORMAL
var air_jumps := 0
var last_y := 0.0
var fall_time := 0.0

# Number of climbables the player is hanging onto at any given time
var climbables := 0
var last_climbable_x := 0.0

func _ready():
	# Allows the 1st call to is_on_floor() to work correctly 
	velocity = move_and_slide(velocity, Vector2.UP, true)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	match state:
		PlayerState.CLIMB:
#			if $RayCast2D.is_colliding() && Input.is_action_pressed("Up"):
#				position = Vector2(position.x, position.y - 5)			
			climb()
#			That way you can get off of any vine or ladder that touches the ground
#			I just want to make sure that we come off like that
			if is_on_floor() && velocity.y > 0:
				change_state(PlayerState.NORMAL)
			
		PlayerState.DIE:
			pass
			
		PlayerState.FALL:
			if is_on_floor():
				change_state(PlayerState.LAND)
			elif fall_time <= MIN_FALL_JUMP_TIME:
				air_jumps = max_air_jumps
				jump()
				
			fall_time += delta
			
		PlayerState.JUMP:
			jump()
			
		PlayerState.LAND:
#			print("fell: %f" % (global_position.y - last_y))
##			So if only our dust timer is finished
##			We are going to emit a particle
#			if $DustTimer.is_stopped() && !$FootDust.emitting && velocity.y > 1:
#				$FootDust.emitting = true
##				We want the dust timer
##				We want to start it
#				$DustTimer.start($FootDust.lifetime + 0.2)  				
			fall_time = 0
			change_state(PlayerState.NORMAL)
			pass
			
		PlayerState.NORMAL:
			if !is_on_floor():
				change_state(PlayerState.FALL)
				last_y = global_position.y
			else:
				horizontal()
				if Input.is_action_just_pressed("Jump"):
					air_jumps = max_air_jumps
					change_state(PlayerState.JUMP)
					jump()
				elif climbables > 0:
					vertical()
#					If the player is trying to go up
#					That will should allows us to climb
					if velocity.y < 0:
#						global_position.x = last_climbable_x
						change_state(PlayerState.CLIMB)
#				If you're colliding with the raycast and
#				you just press the down button
#				we're gonna set him down further in basically 
#				into past the one way collision 
				elif $RayCast2D.is_colliding() && Input.is_action_pressed("Down"):
#					var collider = $RayCast2D.get_collider().get_node("OneWay")
#					collider.disabled = true
#					We want our character stick to the ladder 
					var area = $RayCast2D.get_collider().get_node("Area2D")
					global_position = Vector2(area.global_position.x, global_position.y + 2)
					change_state(PlayerState.CLIMB)

func _physics_process(delta):
	if state != PlayerState.CLIMB:
		velocity.y += GRAVITY * delta
		
	velocity = move_and_slide(velocity, Vector2.UP, true)

func horizontal():
#	if Input.is_action_pressed("Left"):
#		velocity.x = -speed
#		$Sprite.flip_h = true
#	elif Input.is_action_pressed("Right"):
#		velocity.x = speed
#		$Sprite.flip_h = false
#	else: 
#		velocity.x = 0
		
	var action_strength = Input.get_action_strength("Right") - 	Input.get_action_strength("Left")
	velocity.x = action_strength * speed

	if action_strength != 0:
		$Sprite.flip_h = action_strength < 0

	if is_on_floor():
		if velocity.x == 0:
			$Animation.play("Idle")
		else:
			$Animation.play("Walk")

func vertical():
	if Input.is_action_pressed("Up"):
		velocity.y = -speed / 2.0
	elif Input.is_action_pressed("Down"):
		velocity.y = 0.75 * speed
	else: 
		velocity.y = 0

	if state == PlayerState.CLIMB:	
		$Animation.play("Idle")

func change_state(new_state: int):
#	print("Change state from %d to %d" % [state, new_state])
	prev_state = state
	state = new_state

func jump():
	if air_control:
		horizontal()
		
#	We have one jump and that would be just on the floor
	if Input.is_action_just_pressed("Jump") && air_jumps >= 0:
		$Animation.play("Jump")
		
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
	elif is_on_floor() && velocity.y >= 0:
		change_state(PlayerState.LAND)

func climb():
	velocity.x = 0
	vertical()
	
	if Input.is_action_just_pressed("Jump"):
		air_jumps = max_air_jumps
		horizontal()
		change_state(PlayerState.JUMP)
		
		if velocity.x != 0:
			jump()	

func on_interact_entered(obj_pos: Vector2, type):	
#   We're going to snap our player to that x coordinate 
#   when we come into the climb of vine state
#   If we're climbing the chain before 
#   We do not want to go back into the climbing state again
#   We should be able to press the jump button and let go the chain
#	We do not want to jump to the same chain
#   We want to be able to let it go and jump from that one to another one
#   Now we can actually jump in the air from one vine to another
#   and we immediately stick to it  
	if type == InteractType.CHAIN || type == InteractType.LADDER:
		climbables += 1		

		if state == PlayerState.JUMP && ( prev_state != PlayerState.CLIMB || last_climbable_x != obj_pos.x ):						
			global_position.x = obj_pos.x
			change_state(PlayerState.CLIMB)
			
		last_climbable_x = obj_pos.x

# warning-ignore:unused_argument
func on_interact_exited(obj_pos: Vector2, type):	
	if type == InteractType.CHAIN || type == InteractType.LADDER:
#   	I don't want to go below zero
		climbables = int(max(0, climbables - 1))
	
#		So what needs to happen is whenever he gets off of that
#   	He should go to the fall state
		if climbables == 0 && state == PlayerState.CLIMB:
			$Animation.play("Idle")
			change_state(PlayerState.FALL)
			
func on_jump_sfx():
	if !$Jump.playing:
		$Jump.play()
	
	
	
