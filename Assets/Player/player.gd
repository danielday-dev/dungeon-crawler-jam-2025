extends Node3D

@onready var head : Node3D = $Head
@onready var camera : Node3D = $Head/FirstPersonCamera

@onready var map_cam_position: Node3D = $Head/MapCameraPos

const MOVE_SPEED: float = 128.0
const TURN_SPEED: float = 180.0
const TILE_SIZE: float = 64.0
const ROTATE_DEGREES: float = 90.0

var move_amount: float = 0.0
var is_moving: bool = false
var move_direction: Vector3 = Vector3.ZERO

var turn_rotation_amount: float = 0.0
var is_turning: bool = false
var input_turn_direction: float = 0.0

signal onPlayerMove

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _physics_process(delta: float) -> void:	
	_move_tile(delta)
	_turn_head(delta)

func _move_tile(delta):
	if is_moving:
		var next_move_amount = move_toward(move_amount, TILE_SIZE, MOVE_SPEED  * delta)
		position += (next_move_amount - move_amount) * move_direction * delta
		move_amount = next_move_amount
		if move_amount >= TILE_SIZE:
			move_amount = 0.0
			is_moving = false
			print_debug("finish moving")
		return;
	
	# Prioritise forward move over side moves - do not allow diagonals
	var move_input_v := Input.get_axis("up", "down");
	var move_input_h := Input.get_axis("left", "right")
	
	if move_input_v != 0.0 || move_input_h:
		move_direction = (head.transform.basis * Vector3(move_input_h, 0, move_input_v)).normalized()
		is_moving = true
		print_debug("start moving")
		return

func _turn_head(delta: float):
	# Turning cooldown
	if is_turning:
		var next_turn_amount = move_toward(turn_rotation_amount, 90, TURN_SPEED * delta)
		head.rotate_y(deg_to_rad(turn_rotation_amount - next_turn_amount) * input_turn_direction)
		turn_rotation_amount = next_turn_amount
		if turn_rotation_amount >= ROTATE_DEGREES:
			is_turning = false
			print_debug("finished turning")
		return
	
	input_turn_direction = Input.get_axis("look_left", "look_right")
	
	if input_turn_direction == 0.0:
		return
	
	print_debug("turning..")
	is_turning = true
	turn_rotation_amount = 0.0
