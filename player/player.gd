class_name Player extends CharacterBody2D

signal coin_collected()

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -725.0
const TERMINAL_VELOCITY = 700
var GRAVITY: int = ProjectSettings.get("physics/2d/default_gravity")

@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var camera := $Camera as Camera2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var _double_jump_charged := false

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_double_jump_charged = true
	if Input.is_action_just_pressed("jump"):
		try_jump()
	elif Input.is_action_just_released("jump") and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + GRAVITY * delta)

		
	var direction := Input.get_axis("move_left", "move_right") * WALK_SPEED
	if direction > 0:
		animated_sprite_2d.flip_h = false
	if direction < 0: 
		animated_sprite_2d.flip_h = true
	
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()
	
	var animation := get_new_animation()
	if animation != animated_sprite_2d.animation:
		animated_sprite_2d.play(animation)

func get_new_animation() -> String:
	var animation_new: String
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		#if velocity.y > 0.0:
			#animation_new = "falling"
		#else:
		if velocity.y < 0.0:
			animation_new = "jumping"
	return animation_new


func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged:
		_double_jump_charged = false
		velocity.x *= 2.5
		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	#jump_sound.play()
