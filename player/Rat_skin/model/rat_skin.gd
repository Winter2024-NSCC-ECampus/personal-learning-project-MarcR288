extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move() -> void:
	animation_player.play("Rat_Run")
	
func idle() -> void:
	animation_player.play("Rat_Idle")
