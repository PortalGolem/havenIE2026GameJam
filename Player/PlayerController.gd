extends AnimatableBody3D

# the player has movement modes for each controll scheme.

enum MOVEMENT_MODE {GROUND, AIR, WALL, ATTACK}
@export var mouseSensitivity:float 
@export var groundSpeed:float
@export var initialMovementMode:MOVEMENT_MODE

@export var maxXRotation:float
@export var minYRotation:float
@export var maxYRotation:float

var currentRotation := Vector2.ZERO

var currentMovement:MOVEMENT_MODE
var mouseInput := Vector2.ZERO
var movementInput := Vector2.ZERO
var startedAttack:bool = false
var finishedAttack:bool = false
var jumped:bool = false
signal Lockin()
signal UnLockin()
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentMovement = initialMovementMode


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	currentRotation += mouseInput * mouseSensitivity
	basis = Basis.IDENTITY
	
	if currentMovement == MOVEMENT_MODE.GROUND:
		var movement = movementInput.normalized() * groundSpeed * delta
		movement = Vector3(movement.x, 0, movement.y)
		movement = movement.rotated(Vector3.UP, rotation.y)
		position += movement
	elif currentMovement == MOVEMENT_MODE.AIR:
		pass
	elif currentMovement == MOVEMENT_MODE.WALL:
		pass
	elif currentMovement == MOVEMENT_MODE.ATTACK:
		pass
	
	#attack code
	if startedAttack == true:
		#send out the signal to display cursors
		Lockin.emit()
		startedAttack = false
		finishedAttack = false
		
	if finishedAttack == false:
		#start the camera zoom in and slowing at a certain rate of change
		#THESE NUMBERS ARE PLACEHOLDERS.
		var zoom_in_speed = 0.1
		var zoom_in_max = 10
		
		var slow_speed = 0.1
		var slow_max = 10
		
	if finishedAttack == true:
		UnLockin.emit()
	
	
