extends AnimatableBody3D

# the player has movement modes for each controll scheme.

enum MOVEMENT_MODE {GROUND, AIR, WALL, ATTACK, DASH}
@export var mouseSensitivity:float 
@export var groundSpeed:float
@export var airSpeed:float
@export var airDrag:float
@export var airGravity:float
@export var DashSpeed:float
@export var initialMovementMode:MOVEMENT_MODE

@export var maxXRotation:float
@export var minYRotation:float
@export var maxYRotation:float

@export var Camera_FOV_def = 70
@export var Camera_FOV = 70

@export var Game_Speed = 1

#dash variables
@export var dash_time = 180
@export var dash_timer = dash_time
@export var dash_speed = 30
@export var dash_lock_time = 120
@export var dash_lock_timer = dash_lock_time
var dash_buffer_time = 60
var dash_buffer_timer = dash_buffer_time
var dashable = true
var dashing = false


var currentRotation := Vector2.ZERO
var velocity := Vector3.ZERO

var currentMovement:MOVEMENT_MODE


var mouseInput := Vector2.ZERO
var movementInput := Vector2.ZERO
var startedAttack:bool = false
var finishedAttack:bool = false
var jumped:bool = false
var dashed:bool = false
var movementLocked:bool = false
signal Lockin()
signal UnLockin()

@onready var Camera = $Camera3Dd




func _input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			mouseInput = event.relative
		elif event.is_action_pressed("Forward"):
			movementInput.y += -1.0
		elif event.is_action_released("Forward"):
			movementInput.y += 1.0
		elif event.is_action_pressed("Left"):
			movementInput.x += -1.0
		elif event.is_action_released("Left"):
			movementInput.x += 1.0
		elif event.is_action_pressed("Right"):
			movementInput.x += 1.0
		elif event.is_action_released("Right"):
			movementInput.x += -1.0
		elif event.is_action_pressed("Backward"):
			movementInput.y += 1.0
		elif event.is_action_released("Backward"):
			movementInput.y += -1.0
		elif event.is_action_pressed("Attack"):
			startedAttack = true
		elif event.is_action_released("Attack"):
			finishedAttack = true
		elif event.is_action_pressed("Jump"):
			jumped = true
		elif event.is_action_released("Jump"):
			jumped = false
		elif event.is_action_pressed("Dash"):
			dashed = true
		elif event.is_action_pressed("Dash"):
			dashed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentMovement = initialMovementMode


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	print(mouseInput)
	print(currentRotation)
	print(mouseInput * mouseSensitivity)
	currentRotation += mouseInput * mouseSensitivity
	currentRotation.x = clampf(currentRotation.x, -deg_to_rad(maxXRotation), deg_to_rad(maxXRotation))
	currentRotation.y = clampf(currentRotation.y, deg_to_rad(minYRotation), deg_to_rad(maxYRotation))
	basis = Basis.IDENTITY
	$CameraPivot.basis = Basis.IDENTITY
	rotate(Vector3.UP, currentRotation.x)
	$CameraPivot.rotate(Vector3.RIGHT, currentRotation.y)
	mouseInput = Vector2.ZERO
	
	if currentMovement == MOVEMENT_MODE.GROUND:
		var movement = movementInput.normalized() * groundSpeed * delta
		movement = Vector3(movement.x, 0, movement.y)
		movement = movement.rotated(Vector3.UP, rotation.y)
		position += movement
	elif currentMovement == MOVEMENT_MODE.AIR:
		# accept input left and right and change velocity
		velocity.move_toward(Vector3.ZERO, delta * airDrag)
		velocity += Vector3(delta * movementInput.x * airSpeed, 0, 0)
		velocity.y -= airGravity * delta
		position += velocity.rotated(Vector3.UP, rotation.y)
		#Handle dash inputs
		if dashed:
			currentMovement = MOVEMENT_MODE.DASH
	elif currentMovement == MOVEMENT_MODE.WALL:
		#Handle dash inputs
		if dashed:
			currentMovement = MOVEMENT_MODE.DASH
	elif currentMovement == MOVEMENT_MODE.ATTACK:
		#Handle dash inputs
		if dashed:
			currentMovement = MOVEMENT_MODE.DASH
	elif currentMovement == MOVEMENT_MODE.DASH:
		#setup timers
		if dashing == false:
			dash_timer = dash_time
			dash_lock_timer = dash_lock_time
			
			dashing = true
			dashable = false
			
			#GET CAMERA DIRECTION SO WE CAN NORMALIZE OUR MOVEMENT IN THE DIRECTION WE WANNA
		
		dash_lock_timer -= 1
		#if dash_lock_timer <= 0:
			#allow movement to other states
		
		pass
	
	#DASH MOVEMENT CODE
	if dash_timer > 0:
		dash_timer -= 1
		#USE CAMERA DIRECTION TO DEFINE WHERE HE MOVES EACH FRAME
	else:
		dash_buffer_timer = dash_buffer_time
	
		dashing = false
	#DASH BUFFER COUNTDOWN CODE
	if dash_buffer_timer > 0 && dashing == false:
		dash_buffer_timer -= 1
	else:
		dashable = true
	
	#attack code
	if startedAttack == true:
		#send out the signal to display cursors
		Lockin.emit()
		startedAttack = false
		finishedAttack = false
		
	if finishedAttack == false:
		#start the camera zoom in and slowing at a certain rate of change
		#THESE NUMBERS ARE PLACEHOLDERS.
		var zoom_in_speed = 0.015
		var zoom_in_max = 50
		
		var slow_speed = 0.01
		var slow_max = 0.2
		
		Game_Speed -= slow_speed * delta
		Game_Speed = clamp(Game_Speed, 1 - slow_max, 1)
		
		#camera FOV tween
		Camera_FOV += (Camera_FOV * zoom_in_speed)
		Camera_FOV = clamp(Camera_FOV, zoom_in_max, 1000)
		
		#FIND THE ENEMY WE ARE LOOKING AT AND STORE IT.
		
		
		
	#reset to and launch
	if finishedAttack == true:
		UnLockin.emit()
		Game_Speed = 1
		Camera_FOV = Camera_FOV_def
		currentMovement = MOVEMENT_MODE.ATTACK
	
	#CAMERA DYNAMIC FOV CODE GO HERE
	
	
	Camera.FOV = Camera_FOV
	Engine.time_scale = Game_Speed
	
