extends Node3D

var path_spd := 0.01
var death = false
var stanima_gain:float = 20
var cyclic = false
var direction = 1.0

signal E_death(stanima_gain:float)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#type of path logic
	if cyclic == false:
		$"..".loop = false
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	
	
	#back and fourth
	if cyclic == false:
		if $"..".progress_ratio == 1:
			direction = -1
		if $"..".progress_ratio == 0:
			direction = 1
		
		
	
	var cur_path_spd = path_spd * direction
	#path movement
	$"..".progress += cur_path_spd
	print(direction)
	
	if death == true:
		E_death.emit(stanima_gain)
		if is_instance_valid($"../../.."):
			$"../../..".queue_free()
		
	pass
	

	
