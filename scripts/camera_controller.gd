extends Camera2D

signal camera_mode_changed(is_camera_mode: bool)

const CAMERA_SPEED = 200
var is_camera_mode := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_camera_mode(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_camera_mode:
		handle_camera_movement(delta)

func _input(event):
	if event.is_action_pressed("ui_select"):
		toggle_camera_mode()

func toggle_camera_mode():
	set_camera_mode(!is_camera_mode)

func set_camera_mode(enabled: bool):
	is_camera_mode = enabled
	if not is_camera_mode:
		position = Vector2.ZERO
	camera_mode_changed.emit(is_camera_mode)

func handle_camera_movement(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x = -1
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	
	position += direction * CAMERA_SPEED * delta
			
