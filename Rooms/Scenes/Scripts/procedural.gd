extends Node3D

var Start_Room = preload("res://Rooms/Fixed/End_Room.tscn");
var End_Room = preload("res://Rooms/Fixed/End_Room.tscn");

var Random_Rooms = [ResourceLoader.list_directory("res://Rooms/Random/")]
var Room_Amount = 20

var Scene = get_tree().get_root()  

var Continue_position:Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#place the first room
	var Start_Room_Inst = Start_Room.instantiate()
	Scene.add_child(Start_Room_Inst)
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
