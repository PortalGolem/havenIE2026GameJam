extends AnimatableBody3D

# the player has movement modes for each controll scheme.

enum MOVEMENT_MODE {GROUND, AIR, WALL, ATTACK, DASH}
@export var mouseSensitivity:float 
@export var groundSpeed:float
@export var airSpeed:float
@export var airDrag:Vector3
@export var airGravity:float
@export var wallDrag:float
@export var wallGravity:float
@export var wallDistance:float
@export var DashSpeed:float
@export var initialMovementMode:MOVEMENT_MODE

@export var maxXRotation:float
@export var minYRotation:float
@export var maxYRotation:float
@export var jumpVector:Vector3
@export var doubleJumpVector:Vector3
@export var dashVector:Vector3

@export var Camera_FOV_def = 701
@export var Camera_FOV = 70

@export var Game_Speed = 1
@export var minZVelocity: float

#dash variables
@export var dash_time := 180.0
@export var dash_timer := 0
@export var dash_speed := 30.0
@export var dash_lock_time := 120.0
@export var dash_lock_timer := 0
var dashing = false

var stanima_max = 100
@export var stanima = 100
@export var stanima_dash_cost = 10
@export var stanima_jump_cost = 10
@export var stanima_regeneration = 3.5
@export var deathTime:float = 3
var deathTimer:= 0.0
var wallX = 0.0

signal enemy_killed(id)


var currentRotation := Vector2.ZERO
@export var velocity := Vector3.FORWARD * 10
@export var maxAttackDistance:float = 100.0

var currentMovement:MOVEMENT_MODE


var mouseInput := Vector2.ZERO
var movementInput := Vector2.ZERO
var wallCollision:bool = false
var startedAttack:bool = false
var finishedAttack:bool = false
var jumped:bool = false
var dashed:bool = false
var dashDirection:Vector3
var movementLocked:bool = false
var wallNormal:Vector3
signal Lockin()
signal UnLockin()
var targetIDs:Array[int]
var targetPositions:Array[Vector3]
var runFinishedAttack := false
var finalTargetEnemyPosition:Vector3
var finalTargetEnemyID:int
var died = false
@export var doubleJumpLimit:int
@export var dashLimit:int
@export var enemySize:float
var currentDoubleJumps:int
var currentDashes:int
@onready var Camera = $CameraPivot/Camera3D




func _input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			mouseInput = event.relative
		elif event.is_action_pressed("Forward"):
			movementInput.y += -1.0
		elif event.is_action_released("Forward"):
			movementInput.y += 1.0
		elif event.is_action_pressed("Left"):
			movementInput.x += 1.0
		elif event.is_action_released("Left"):
			movementInput.x += -1.0
		elif event.is_action_pressed("Right"):
			movementInput.x += -1.0
		elif event.is_action_released("Right"):
			movementInput.x += 1.0
		elif event.is_action_pressed("Backward"):
			movementInput.y += 1.0
		elif event.is_action_released("Backward"):
			movementInput.y += -1.0
		#elif event.is_action_pressed("Attack"):
		#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#	startedAttack = true
		#elif event.is_action_released("Attack"):
		#	finishedAttack = true
		elif event.is_action_pressed("Jump"):
			jumped = true
		elif event.is_action_released("Jump"):
			jumped = false
		elif event.is_action_pressed("Dash"):
			dashed = true
		elif event.is_action_pressed("Settings"):
			if died:
				get_tree().change_scene_to_file("res://Scenes/Main.tscn")
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 1.0
	

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentMovement = initialMovementMode


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if died and deathTimer < deathTime:
		deathTimer += delta
		$DeathScreen.modulate = Color(255, 255, 255, deathTimer/deathTime)
		Engine.time_scale = 1 - deathTimer/deathTime
	#STANIMA CODE
	stanima += stanima_regeneration * delta
	$StanimaBar.Stanima = stanima
	stanima = clamp(stanima, 0, stanima_max)
	currentRotation += -mouseInput * mouseSensitivity
	currentRotation.x = clampf(currentRotation.x, deg_to_rad(-maxXRotation + 180), deg_to_rad(maxXRotation + 180))
	currentRotation.y = clampf(currentRotation.y, deg_to_rad(minYRotation), deg_to_rad(maxYRotation))
	rotation = Vector3.ZERO
	$CameraPivot.rotation = Vector3.ZERO
	rotate(Vector3.UP, currentRotation.x)
	$CameraPivot.rotate(Vector3.RIGHT, currentRotation.y)
	mouseInput = Vector2.ZERO
	
	if currentMovement == MOVEMENT_MODE.GROUND:
		var movement = movementInput.normalized() * groundSpeed * delta
		movement = Vector3(movement.x, 0, movement.y)
		movement = movement.rotated(Vector3.UP, rotation.y)
		position += movement
		wallCollision = false
	elif currentMovement == MOVEMENT_MODE.AIR:
		# accept input left and right and change velocity
		velocity = move_towards_tripple_vector(-Vector3.BACK * minZVelocity, velocity, delta * airDrag)
		velocity += Vector3(delta * movementInput.x * airSpeed, 0, 0)
		velocity.y -= airGravity * delta
		position += Vector3(velocity.x, velocity.y, -velocity.z) * delta
		#Handle dash inputs
		check_double_jump()
		check_dash()
		check_wall()
	elif currentMovement == MOVEMENT_MODE.WALL:
		velocity.x = 0
		velocity.y -= wallGravity * delta
		velocity = velocity.move_toward(Vector3.FORWARD * minZVelocity, wallDrag * delta)
		position += Vector3(velocity.x, velocity.y, -velocity.z) * delta
		if (wallNormal.x > 0):
			position.x = wallX - wallDistance
		else:
			position.x = wallX + wallDistance
		check_wall_jump()
		#Handle dash inputs
		check_dash()
		wallCollision = false
	elif currentMovement == MOVEMENT_MODE.ATTACK:
		position += (finalTargetEnemyPosition - position).normalized() * 10 * delta
		check_dash()
	elif currentMovement == MOVEMENT_MODE.DASH:
		#setup timers
		if dashing == false:
			dash_timer = dash_time
			dash_lock_timer = dash_lock_time
			dashing = true
			
			#apparently this gets forwards.
			dashDirection = -global_basis.z
		
		if wallCollision:
			dashDirection = Vector3.BACK
		
		dash_lock_timer -= delta
		if dash_lock_timer <= 0:
			if wallCollision:
				currentMovement = MOVEMENT_MODE.WALL
				wallCollision = false
			else:
				currentMovement = MOVEMENT_MODE.AIR
	
	#DASH MOVEMENT CODE
	if dash_timer > 0:
		dash_timer -= delta
		position += (dashDirection * (DashSpeed + velocity.y) ) * delta
	elif dashing:
		velocity.y = 0
		velocity.x = 0
		velocity += Vector3(-dashVector.x, dashVector.y, -dashVector.z)
		dashing = false
	
	
	#attack code
	if startedAttack == true:
		#send out the signal to display cursors
		Lockin.emit()
		var cursors:Array[LockInCursor]
		findByClass(get_tree().root, "LockInCursor", cursors)
		var index:int = 0
		for cursor in cursors:
			if cursor.position.distance_to(position) < maxAttackDistance:
				targetPositions.append(cursor.position)
				targetIDs.append(index)
			index += 1
		startedAttack = false
		finishedAttack = false
		runFinishedAttack = false
	
	var targetedPositions:Array[Vector3]
	var targetedUVs:Array[Vector2]
	var targetedIDs:Array[int]
	
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
		
		
		
		var viewport_size:Vector2 = get_viewport().get_visible_rect().size
		var index:int = 0
		for point in targetPositions:
			var pointUV:Vector2 = Camera.unproject_position(point) / viewport_size
			if pointUV.distance_to(Vector2.ONE * .5) < enemySize:
				targetedIDs.append(targetIDs[index])
				targetedPositions.append(point)
			index += 1
		
		
	#reset to and launch
	if finishedAttack == true and runFinishedAttack == false:
		print("attackFinalized")
		if targetedIDs.size() > 0:
			print("enemyFound")
			UnLockin.emit()
			Game_Speed = 1
			Camera_FOV = Camera_FOV_def
			
			var closestEnemy:float = INF
			for i in range(targetedIDs.size()):
				var testDistance = targetedUVs[i].distance_to(Vector2.ONE * .5)
				if testDistance < closestEnemy:
					finalTargetEnemyID = targetedIDs[i]
					finalTargetEnemyPosition = targetedPositions[i]
					closestEnemy = testDistance
			currentMovement = MOVEMENT_MODE.ATTACK
		runFinishedAttack = true
	#CAMERA DYNAMIC FOV CODE GO HERE
	
	
	#Camera.FOV = Camera_FOV
	#Engine.time_scale = Game_Speed
	
func _playerEnterWallCollider(wall:Node3D):
	wallNormal = wall.global_position - global_position
	wallX = wall.global_position.x
	if (wallNormal.x > 0):
		global_position.x = wallX - wallDistance
	else:
		global_position.x = wallX + wallDistance
	
	wallCollision = true
func _playerEnterFloorCollider(floor:Node3D):
	died = true
	
func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className) :
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)
	
func check_dash():
	if dashed && currentDashes < doubleJumpLimit && stanima > stanima_dash_cost:
		currentDashes += 1
		currentDashes = min(currentDashes, dashLimit)
		stanima -= stanima_dash_cost
		dashed = false
		currentMovement = MOVEMENT_MODE.DASH
func check_wall():
	if wallCollision:
			currentMovement = MOVEMENT_MODE.WALL
			wallCollision = false

func move_towards_tripple_vector(target:Vector3, startingPosition:Vector3, ammount:Vector3) -> Vector3:
	var returnAmmount:Vector3
	if startingPosition.x > target.x:
		returnAmmount.x = startingPosition.x - ammount.x
		returnAmmount.x = max(target.x, returnAmmount.x)
	else:
		returnAmmount.x = startingPosition.x + ammount.x
		returnAmmount.x = min(target.x, returnAmmount.x)
	
	if startingPosition.y > target.y:
		returnAmmount.y = startingPosition.y - ammount.y
		returnAmmount.y = max(target.y, returnAmmount.y)
	else:
		returnAmmount.y = startingPosition.y + ammount.y
		returnAmmount.y = min(target.y, returnAmmount.y)
	
	if startingPosition.z > target.z:
		returnAmmount.z = startingPosition.z - ammount.z
		returnAmmount.z = max(target.z, returnAmmount.z)
	else:
		returnAmmount.z = startingPosition.z + ammount.z
		returnAmmount.z = min(target.z, returnAmmount.z)
		
	return returnAmmount

func check_wall_jump():
	if jumped && stanima > stanima_jump_cost:
		jumped = false
		stanima -= stanima_jump_cost
		velocity.y = 0
		if (wallNormal.x > 0):
			velocity += Vector3(-jumpVector.x, jumpVector.y, -jumpVector.z)
		else:
			velocity += Vector3(jumpVector.x, jumpVector.y, -jumpVector.z)
		currentMovement = MOVEMENT_MODE.AIR
		currentDashes = 0
		currentDoubleJumps = 0

func check_double_jump():
	if jumped && currentDoubleJumps < doubleJumpLimit && stanima > stanima_jump_cost:
		jumped = false
		currentDoubleJumps += 1
		currentDoubleJumps = min(currentDoubleJumps, doubleJumpLimit)
		stanima -= stanima_jump_cost
		velocity.y = 0
		velocity += Vector3(doubleJumpVector.x, doubleJumpVector.y, -doubleJumpVector.z)

func find_child_recursive(target: Node) -> AnimationTree:
	for child in target.get_children():
		if child is AnimationTree:
			return child

		var result := find_child_recursive(child)
		if result != null:
			return result

	return null
