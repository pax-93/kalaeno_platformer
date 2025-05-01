class_name Player extends CharacterBody2D

signal coin_collected()

const WALK_SPEED: int = 300.0
const FLYING_SPEED: int = 500.0
const ACCELERATION_SPEED: int = WALK_SPEED * 6.0
const JUMP_VELOCITY: int = -725.0
const DOWNWARD_X_ATTACK_VELOCITY: int = 800.0
const DOWNWARD_Y_ATTACK_VELOCITY: int = 1300.0
const TERMINAL_VELOCITY: int = 700
const MAX_VELOCITY: int = 1000

var GRAVITY: int = ProjectSettings.get("physics/2d/default_gravity")
var DIRECTION = Vector2.RIGHT

@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var camera := $Camera as Camera2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var stamina_replenish: Timer = $StaminaReplenish

var strong_fly_movement_timer_cooldown

var engage_hovering_state_timer
var hovering: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		try_fly()
	elif Input.is_action_just_released("jump") and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	# Fall.
	if not hovering:
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + GRAVITY * delta)
	
	if not is_on_floor() and hovering:
		velocity.y *= 0.975
		if velocity.y >= 0:
			velocity.y = 0
	
	if is_on_floor():
		hovering = false
		PlayerState.set_attacking_state(false)
	
	if Input.is_action_just_pressed("move_down"):
		hovering = false
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + GRAVITY * delta)
	
	var direction
	if hovering:
		direction = Input.get_axis("move_left", "move_right") * FLYING_SPEED
	else:
		direction = Input.get_axis("move_left", "move_right") * WALK_SPEED
	var just_switched_direction: bool = false
	if direction > 0:
		animated_sprite_2d.flip_h = false
		if DIRECTION != Vector2.RIGHT:
			just_switched_direction = true
		DIRECTION = Vector2.RIGHT
		if just_switched_direction:
			just_switched_direction = false
	if direction < 0: 
		animated_sprite_2d.flip_h = true
		if DIRECTION != Vector2.LEFT:
			just_switched_direction = true
		DIRECTION = Vector2.LEFT
		if just_switched_direction:
			just_switched_direction = false
	
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	floor_stop_on_slope = not platform_detector.is_colliding()

	move_and_slide()
	
	var animation = get_new_animation()
	if animation != animated_sprite_2d.animation and not PlayerState.get_attacking_state():
		animated_sprite_2d.play(animation)
		
	if Input.is_action_just_pressed("attack") and not PlayerState.get_attacking_state():
		try_attack()

func get_new_animation() -> String:
	var animation_new: String
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		#if PlayerState.get_attacking_state():
			#animation_new = "down_air_attack"
		#if velocity.y > 0.0:
			#animation_new = "falling"
		#else:
		if velocity.y < 0.0:
			animation_new = "jumping"
	return animation_new


func try_fly() -> void:
	PlayerState.set_attacking_state(false)
	if PlayerState.get_player_stamina() < 5:
		return
	else:
		velocity.y = JUMP_VELOCITY
		
		if !engage_hovering_state_timer:
			engage_hovering_state_timer = get_tree().create_timer(0.4)
			engage_hovering_state_timer.timeout.connect(_attempting_to_engage_hovering_state)
		else:
			hovering = true
		
		if is_on_floor() and !strong_fly_movement_timer_cooldown:
			velocity.x *= 2.4
			velocity.y *= 2.0
		else:
			velocity.x *= 3.6
			velocity.y *= 1.4
		
		_limit_player_velocity()
			
		if !strong_fly_movement_timer_cooldown:
			strong_fly_movement_timer_cooldown = get_tree().create_timer(1)
			strong_fly_movement_timer_cooldown.timeout.connect(_free_strong_fly_cooldown_timer)
		SignalBus.player_use_stamina.emit(5)

func try_attack() -> void:
	if PlayerState.get_player_stamina() > 10:
		PlayerState.set_attacking_state(true)
		hovering = false
		
		
		if !is_on_floor():
			animated_sprite_2d.stop()
			animated_sprite_2d.play("down_air_attack")
			if DIRECTION == Vector2.RIGHT:
				velocity.x = DOWNWARD_X_ATTACK_VELOCITY
			else:
				velocity.x = -DOWNWARD_X_ATTACK_VELOCITY
			velocity.y = DOWNWARD_Y_ATTACK_VELOCITY
			PlayerState.set_attacking_state(false)
			return
			
		animated_sprite_2d.stop()
		animated_sprite_2d.play("forward_ground_attack")

		PlayerState.set_attacking_state(false)
	#_limit_player_velocity()

func _attempting_to_engage_hovering_state() -> void:
	engage_hovering_state_timer = null

func _free_strong_fly_cooldown_timer() -> void:
	strong_fly_movement_timer_cooldown = null

func _on_stamina_replenish_timeout() -> void:
	SignalBus.player_gain_stamina.emit(15)

func _limit_player_velocity() -> void:
	# caps the max velocity in x
	if velocity.x > 0 and velocity.x > MAX_VELOCITY:
		velocity.x = MAX_VELOCITY
	elif velocity.x < 0 and velocity.x < -MAX_VELOCITY:
		velocity.x = -MAX_VELOCITY

	# caps the max velocity in y
	if velocity.y > 0 and velocity.y > MAX_VELOCITY:
		velocity.y = MAX_VELOCITY
	elif velocity.y < 0 and velocity.y < -MAX_VELOCITY:
		velocity.y = -MAX_VELOCITY

func _on_collision_shape_2d_child_entered_tree(node: Node) -> void:
	animated_sprite_2d.play("run")
