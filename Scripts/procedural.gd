extends Node3D

var Start_Room = preload("res://Rooms/Fixed/Start_Room.tscn");
var Start_Room_Inst
var End_Room = preload("res://Rooms/Fixed/End_Room.tscn");
var End_Room_Inst

var Random_Rooms = [ResourceLoader.list_directory("res://Rooms/Random/")]
var Room_Amount = 20
var Rand_Room_Inst:Array
var Scene  

var Continue_position:Vector3 = Vector3(0, 0, 0)
var Rotation_Amount = 0.00

var delay = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scene = get_tree().root.get_child(0)
	
	#place the first room
	Start_Room_Inst = Start_Room.instantiate()
	Scene.add_child.call_deferred(Start_Room_Inst)
	
	
	for i in Room_Amount:

		var Room_Rand = Random_Rooms[randi_range(0, Random_Rooms.size())-1]
		var Room = load("res://Rooms/Random/" + Room_Rand[0])
		Rand_Room_Inst.append(Room.instantiate())
		Scene.add_child.call_deferred(Rand_Room_Inst[i])
		
	
	
	End_Room_Inst = End_Room.instantiate()
	Scene.add_child.call_deferred(End_Room_Inst)
	
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if delay >= 0:
		delay -= 1
	if delay == 0:
		Start_Room_Inst.global_position = Continue_position
		Continue_position = Start_Room_Inst.find_child("End").global_position;
		
		for i in Room_Amount:
			Rand_Room_Inst[i].global_position = Continue_position
			Continue_position = Rand_Room_Inst[i].find_child("End").global_position;
		
		End_Room_Inst.global_position = Continue_position
	
	pass
