extends Control

var Stanima = 100
var Stanima_full = 188.0
var Player 
var x_to = Stanima_full
var speed = 0.75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player = get_tree().get_root()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	x_to = Stanima_full * (Stanima/100)

	
	#tween the bar
	$Node2D/ColorRect.size.x += ((x_to - $Node2D/ColorRect.size.x)/speed) * delta
	
	pass
