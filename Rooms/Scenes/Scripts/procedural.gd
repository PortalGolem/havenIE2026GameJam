extends Node3D

var Start_Room = preload("res://Rooms/Fixed/End_Room.tscn");
var End_Room = preload("res://Rooms/Fixed/End_Room.tscn");

var Random_Rooms = [ResourceLoader.list_directory("res://Rooms/Random/")]
var Room_Amount = 20

var Scene = get_tree().get_root()  

var Continue_position:Vector3
var Rotation_Amount = 0.00

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#place the first room
	var Start_Room_Inst = Start_Room.instantiate()
	Scene.add_child(Start_Room_Inst)
	Continue_position = Start_Room_Inst.find_child("End").global_position;
	
	for i in Room_Amount:
		var Room_Cur_Inst = Random_Rooms.pick_random().instantiate()
		Scene.add_child(Room_Cur_Inst)
		Room_Cur_Inst.global_position = Continue_position
		Continue_position = Room_Cur_Inst.find_child("End").global_position;
	
	var End_Room_Inst = End_Room.instantiate()
	Scene.add_child(End_Room_Inst)
	End_Room_Inst.global_position = Continue_position
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
