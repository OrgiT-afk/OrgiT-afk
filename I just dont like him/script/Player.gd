extends KinematicBody2D
 
var velocity = Vector2.ZERO
var horizontalDir = Vector2.ZERO
var speedLimit = 115
var speedTourque = 900

onready var maxPlayerStammina = 120
onready var playerStamina = maxPlayerStammina

onready var isFalling = false
onready var isJumping = false
onready var isInTheAir = false
onready var fallingMomentum = false

var canJump = false

export (float, 0, 1) var coyoteTime = 0.08
export var jumpBuffering = .1
var hasPressedJump = false
export var minJump  = 8

export var jump_height = 30
export var jump_time_to_peak = 0.32
export var jump_time_to_descent = 0.28

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _physics_process(delta):
	_horizontal()
	_on_gravity()
	_wall_sliding()
	_stamina_recharge()
	
	velocity.y += _get_gravity() * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	pass

func _stamina_recharge():
	if is_on_floor():
		playerStamina = maxPlayerStammina

func _process(delta):
	_checksIfPlayerOnFloor()
	_checkJump()

func _on_gravity():
	if isFalling:
		$AnimationPlayer.play("fall")
	if isJumping:
		$AnimationPlayer.play("jump")

func _get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _checksIfPlayerOnFloor():
	if is_on_floor():
		canJump = true
	else:
		if canJump == true:
			yield(get_tree().create_timer(coyoteTime), "timeout")
			canJump = false
	pass

func _rightColliding():
	return true if $WallRCR.is_colliding() else false

func _leftColliding():
	return true if $WallRCL.is_colliding() else false

func _wall_sliding():
	if _leftColliding() and velocity.y > 0:
		$Sprite.flip_h = true
		velocity.y = 30
		if Input.is_action_just_pressed("jump") and playerStamina >= 40:
			playerStamina -= 40
			velocity.x = -jump_velocity
			velocity.y = jump_velocity
	if _rightColliding() and velocity.y > 0:
		$Sprite.flip_h = false
		velocity.y = 30
		if Input.is_action_just_pressed("jump") and playerStamina >= 40:
			playerStamina -= 40
			velocity.x = jump_velocity
			velocity.y = jump_velocity

func _checkJump():
	#checks if the player has pressed jump, if they did and the jump buffering timer has not started yet, start it.
	if Input.is_action_just_pressed("jump") and hasPressedJump == false:
		
		hasPressedJump = true
		yield(get_tree().create_timer(jumpBuffering), "timeout")
		hasPressedJump = false
		
	if canJump and hasPressedJump:
		velocity.y = jump_velocity
		$JumpParticles.emitting = true
		yield(get_tree().create_timer(0.02),"timeout")
		$JumpParticles.emitting = false
	
	if isFalling:
		fallingMomentum = true
	else:
		yield(get_tree().create_timer(0.5),"timeout")
		fallingMomentum = false
	
	if fallingMomentum and is_on_floor():
		$ImpactParticles.emitting = true
		yield(get_tree().create_timer(0.02),"timeout")
		$ImpactParticles.emitting = false
		
	
	if not Input.is_action_pressed("jump") and isJumping:
		velocity.y = velocity.y/7
	
	if not is_on_floor():
		speedTourque = 650
	elif is_on_floor():
		speedTourque = 900
	
	if velocity.y > 0:
		isFalling = true
	else:
		isFalling = false
	if velocity.y < 0:
		isJumping = true
	else:
		isJumping = false
		
func _horizontal():
	var horizontalVector = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
	velocity.x = move_toward(velocity.x, speedLimit * horizontalVector , speedTourque * get_physics_process_delta_time())
	#animation
	if velocity.x != 0 and is_on_floor():
		$RunParticles.emitting = true
	else:
		$RunParticles.emitting = false
	if velocity.x > 0:
		$Sprite.flip_h = false
	elif velocity.x < 0:
		$Sprite.flip_h = true
	if horizontalVector != 0 and is_on_floor():
		$AnimationPlayer.play("Run")
	else:
		$AnimationPlayer.play("Idle")
	pass



func _on_EnergyToken_body_entered(body):
	playerStamina = maxPlayerStammina
