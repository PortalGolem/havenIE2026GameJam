extends Node3D

var path_spd := 0.01
var death = false
var stanima_gain:float = 20
var cyclic = false
var direction = 1.0
var Scene
var Player
var id


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scene = get_tree().root.get_child(0)
	Player = Scene.find_child("Player", true)
	Player.enemy_killed.connect(death_global);
	#type of path logic
	#$"..".loop = cyclic
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#back and fourth
	#if cyclic == false:
		#if $"..".progress_ratio == 1:
			#direction = -1
		#if $"..".progress_ratio == 0:
			#direction = 1
		
		
	
	var cur_path_spd = path_spd * direction
	#path movement
	#$"..".progress += cur_path_spd
	
	if death == true:
		if is_instance_valid($"../../.."):
			$"../../..".queue_free()
		
	pass
	
func death_global(id):
	death = true
	#write code to check the ID against self 2 know if died
	

	
