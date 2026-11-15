class_name LockInCursor
extends AnimatedSprite3D

var Player_Lockin = true





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Scene = get_tree().root.get_child(0)
	var Player = Scene.find_child("Player")
	#Player.UnLockin.connect(_UnLockin)
	pass # Replace with function body.

func Lockin():
	visible = true

func _UnLockin():
	visible = false
	
