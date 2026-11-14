extends AnimatedSprite3D

var Player_Lockin = true

var Scene = get_tree().get_root()
var Player = Scene.find_child("Player")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.Lockin.connect(Lockin())
	Player.UnLockin.connect(UnLockin())
	pass # Replace with function body.

func Lockin():
	visible = true

func UnLockin():
	visible = false
	
