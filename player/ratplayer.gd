extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %Ratskin



var _camera_input_direction := Vector2.ZERO
#store the last move direction
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"): #release the cursor on escape key/allow user to use mouse
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
		var is_camera_motion := (
			event is InputEventMouseMotion and 
			Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		)
		if is_camera_motion:
			_camera_input_direction = event.screen_relative * mouse_sensitivity

# -PI / 6.0 == -30degrees 
# PI / 3.0 = 60 degrees
func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	#reset the camera to avoid unintended camera movement
	_camera_input_direction = Vector2.ZERO
	#Get an input vector
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#Extract the forward and right direction vectors
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	#calculate the move direction
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0 #to avoid moving into the ground
	move_direction = move_direction.normalized() #normalize to give a direction in the ground plane
	#Calculate character's velocity
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	#Calculate vertical velocity (Character has gravity and can fall)
	velocity.y = y_velocity + _gravity * delta
	
	#Jumping
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse
	move_and_slide() #move the character
	
	#store last move direction
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	#turn towards the last move direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	#use lerp_angle to calculate special score angles
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	
	var ground_speed := velocity.length()
	if ground_speed > 0.0:
		_skin.move()
	else:
		_skin.idle()
