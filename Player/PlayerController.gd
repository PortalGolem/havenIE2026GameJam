extends AnimatableBody3D

# the player has movement modes for each controll scheme.

enum MOVEMENT_MODE {GROUND, AIR, WALL, ATTACK}
@export var groundSpeed:float
@export var initialMovementMode:MOVEMENT_MODE
var currentMovement:MOVEMENT_MODE
var mouseInput:Vector2 = Vector2.ZERO
var movementInput:Vector2 = Vector2.ZERO
var startedAttack:bool = false
var finishedAttack:bool = false
var jumped:bool = false

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
	
	if currentMovement == MOVEMENT_MODE.GROUND:
		var movement = movementInput.normalized() * groundSpeed * delta
		movement = Vector3(movement.x, 0, movement.y)
		movement = movement.rotated(Vector3.UP, rotation.y)
		position += movement
