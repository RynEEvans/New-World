extends CharacterBody2D


@export var walk_speed : float = 200.0
@export var jump_velocity : float = -250.0
@export var double_jump_velocity : float = -100.0
@export var dash_speed : float = 2000.0
@export var player_gravity : float = 1

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var fuelbar = $CanvasLayer/Fuelbar

var has_double_jumped : bool = false
var jetpack_fuel : int = 2
var max_fuel : int = 2
var animation_locked : bool = false
var movement_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false
var dashing : bool = false
var dashDirection = Vector2(1,0)

func _ready():
	jetpack_fuel = 2
	fuelbar.init_jetfuel(jetpack_fuel)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * player_gravity
		was_in_air = true
	else:
		has_double_jumped = false
		
		if was_in_air == true:
			land()

		was_in_air = false
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			#Normal Jump from Floor
			jump()
		elif jetpack_fuel != 0:
			#Double Jump in the Air
			double_jump()
			remove_jetfuel()

	#Handle Dash
	if Input.is_action_just_pressed("dash") && jetpack_fuel != 0:
		dashing = true
		dash()
		remove_jetfuel()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if direction && movement_locked == false:
		if dashing == true:
			dash()
		else:
			velocity.x = direction.x * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		
	move_and_slide()
	update_animation()
	update_facing_direction()

func update_animation():
	if not animation_locked:
		if not is_on_floor():
			animated_sprite.play("JumpLoop")
		else:
			if direction.x != 0:
				animated_sprite.play("Run")
			else:
				animated_sprite.play("Idle")

func update_facing_direction():
	if direction.x > 0:
		dashDirection = Vector2(1,0)
		animated_sprite.flip_h = false
	elif direction.x < 0:
		dashDirection = Vector2(-1,0)
		animated_sprite.flip_h = true

func jump():
	$jump_height_timer.start()
	velocity.y = jump_velocity
	animated_sprite.play("JumpStart")
	animation_locked = true
	print($jump_height_timer.time_left)
	
func double_jump():
	velocity.y = double_jump_velocity * 3
	animated_sprite.play("JumpDouble")	
	animation_locked = true
	has_double_jumped = true
	
func dash():
	if animated_sprite.flip_h == false:
		velocity = dashDirection.normalized() * dash_speed
		velocity.y = 0
		animated_sprite.play("Dash")
		animation_locked = true
		movement_locked = true
		$dash_timer.start()
	else:
		velocity = dashDirection.normalized() * dash_speed
		velocity.y = 0
		animated_sprite.play("Dash")
		animation_locked = true
		movement_locked = true
		$dash_timer.start()

func land():
	animated_sprite.play("JumpEnd")
	animation_locked = true
 
func _set_jetfuel(value):
	fuelbar._set_jetfuel(value)

func add_jetfuel():
	jetpack_fuel = jetpack_fuel + 1
	_set_jetfuel(jetpack_fuel)

func remove_jetfuel():
	jetpack_fuel = jetpack_fuel - 1
	_set_jetfuel(jetpack_fuel)
	check_jetfuel()
	if(jetpack_fuel == 1): 
		$fuel_timer1.start()
	else:
		$fuel_timer2.start()
		if($fuel_timer1.time_left == 0):
			$fuel_timer1.start()

func check_jetfuel():
	if(jetpack_fuel != max_fuel):
		if(jetpack_fuel == 1):
			if ($fuel_timer1.time_left == 0):
				$fuel_timer1.start()
			else:
				pass
		elif (jetpack_fuel == 0):
			if($fuel_timer2.time_left != 0):
				$fuel_timer2.start()
			else:
				pass
		if(jetpack_fuel > 2):
			jetpack_fuel = 2
			_set_jetfuel(jetpack_fuel)
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if(["JumpEnd","JumpStart","JumpDouble","Dash"].has(animated_sprite.animation)):
		animation_locked = false


func _on_dash_timer_timeout() -> void:
	dashing = false
	movement_locked = false

func _on_fuel_timer_1_timeout() -> void:
	add_jetfuel()
	check_jetfuel()
	

func _on_fuel_timer_2_timeout() -> void:
	add_jetfuel()
	check_jetfuel()


func _on_jump_height_timer_timeout() -> void:
	if !(Input.is_action_pressed("jump")):
		if (velocity.y < -75):
			velocity.y = 75
	else:
		print("High Jump")

func killPlayer():
	position = %RespawnPoint.position

func _on_area_2d_body_entered(body: Node2D) -> void:
	killPlayer()
