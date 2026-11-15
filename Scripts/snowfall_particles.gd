extends GPUParticles3D

var z_ahead
var original_position_global
var position_global

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_ahead = abs($"..".position.z - $".".x)  
	original_position_global = $".".global_position
	position_global = original_position_global
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $"..".global_position.z >= 55 - z_ahead + $".".global_position:
		position_global = $"..".global_position.z + z_ahead
	
	$".".global_position = position_global
	
	pass
