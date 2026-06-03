extends CharacterBody2D


@export var walk_speed : float = 200.0
@export var jump_velocity : float = -250.0
@export var double_jump_velocity : float = -100.0
@export var dash_speed : float = 2000.0
@export var player_gravity : float = 1

@onready var player_sprite : AnimatedSprite2D = $Body #The Main Character Body
@onready var gun_sprite : AnimatedSprite2D = $GunArm #The Right Arm Sprite which holds the gun
@onready var fuelbar = $CanvasLayer/PanelContainer/FuelBar #The Fuel Bar UI
@onready var healthbar = $CanvasLayer/PanelContainer2/HealthBar #The Healthbar UI
@onready var o2bar = $CanvasLayer/PanelContainer5/O2Bar #The O2 Bar
@onready var headUI = $CanvasLayer/PanelContainer4/Head #The Head UI
@onready var main = get_tree().get_root().get_node(".") #Lowkey forgot what this does, and why I have it
@onready var bullet = load("res://Entities/Projectiles/Bullet/bullet.tscn") #The Bullet Sprite

#Movement
var direction : Vector2 = Vector2.ZERO

#Jetpack/Fuel
var jetpack_fuel : int = 2
var max_fuel : int = 2

#Dashing
var dashing : bool = false
var dashDirection = Vector2(1,0)

#Checks
var was_on_floor = is_on_floor()
var was_in_air : bool = false
var can_coyote_jump : bool = false
var jump_buffered : bool = false
var has_double_jumped : bool = false

#Knockback Stuff
var knockback: Vector2
var min_knockback := 100
var slow_knockback := 1.1

#Animation Stuff
var facing_left : bool = false
var animation_locked : bool = false
var movement_locked : bool = false

#Gun Stuff
var spawnPos : Vector2
var spawnRot : float
var can_shoot: bool = true
@export var mag_size : int = 10
var max_mag_size : int = 10

#Health Stuff
var health = 10
var health_max = 10
var health_min = 0
var has_died : bool = false

#O2 Stuff
var o2 = 100
var o2_max = 100
var o2_min = 0
var suffocating = false

func _ready():
	health = 10
	o2 = 10
	update_health_bar()
	update_o2_bar()
	$Timers/o2_timer.start()
	jetpack_fuel = 2
	fuelbar.play("tankFull")
	

func _physics_process(delta: float):
	if knockback.length() > min_knockback:
		knockback /= slow_knockback
		if is_on_floor():
			velocity = Vector2(knockback.x, -500)
		else:
			velocity = knockback
		move_and_slide()
		return
	
	# Add the gravity.
	if not is_on_floor() && can_coyote_jump == false:
		velocity += get_gravity() * delta * player_gravity
		was_in_air = true
	else:
		has_double_jumped = false
		
		if was_in_air == true:
			land()

		was_in_air = false
		
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		#Coyote Jump code
		
		#Coyote Jump gives the player some extra time to jump after falling
		#to make Jumping more accesible and not as frame perfect
		#think of Wil E Coyote and how he can jump mid air sometimes
		if is_on_floor() || can_coyote_jump:
			#Normal Jump from Floor
			jump()
			if can_coyote_jump:
				can_coyote_jump = false
			else:
				if !jump_buffered:
					jump_buffered = true
					$Timers/jump_buffer_timer.start()
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
	direction = Input.get_vector("left", "right", "up", "down")
	if direction && movement_locked == false:
		if dashing == true:
			dash()
		else:
			velocity.x = direction.x * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		

	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	#Started to fall
	if (was_on_floor && !is_on_floor() && velocity.y >= 0):
		can_coyote_jump = true
		$Timers/coyote_timer.start()
	
	#touched ground
	if not was_on_floor && is_on_floor():
		if jump_buffered:
			jump_buffered = false
			jump()
	
	update_animation()
	update_facing_direction()


#Animation Code
func update_animation():
	if(Input.is_action_pressed("shoot")):
		shoot()
	if not animation_locked || not movement_locked:
		if health <= 0:
			killPlayer()
		elif not is_on_floor():
			player_sprite.play("ExploJumpLoop")
		else:
			if direction.x != 0:
				if facing_left == false:
					player_sprite.play("RunRight")
					gun_sprite.visible = true
					gun_sprite.z_index = 0
					gun_sprite.play("GunWalkRight")
				else:
					facing_left = true
					player_sprite.play("RunLeft")
					gun_sprite.visible = true
					gun_sprite.z_index = -1
					gun_sprite.play("GunWalkLeft")
			else:
				if(Input.is_action_pressed("shoot")):
					gun_sprite.visible = true
					if(facing_left == false):
						gun_sprite.z_index = 0
						gun_sprite.play("ShootRight")
					else:
						gun_sprite.z_index = -1
						gun_sprite.play("ShootLeft")
					shoot()
				else:
					if (facing_left == true):
						player_sprite.play("IdleLeft")
						gun_sprite.visible = false
					else:
						player_sprite.play("IdleRight")
						gun_sprite.visible = false

#Changes the Boolean (facing_left) so I know whether to play the right or left animation
func update_facing_direction():
	if direction.x > 0:
		dashDirection = Vector2(1,0)
		facing_left = false
	elif direction.x < 0:
		dashDirection = Vector2(-1,0)
		facing_left = true

#Health and Health Bar Code
func update_health_bar():
	if health >= 10:
		health = 10
		healthbar.play("10")
		headUI.play("Full")
	elif health == 9:
		healthbar.play("9")
		headUI.play("Full")
	elif health == 8:
		healthbar.play("8")
		headUI.play("Full")
	elif health == 7:
		healthbar.play("7")
		headUI.play("Full")
	elif health == 6:
		healthbar.play("6")
		headUI.play("Full")
	elif health == 5:
		healthbar.play("5")
		headUI.play("Full")
	elif health == 4:
		healthbar.play("4")
		headUI.play("Full")
	elif health == 3:
		healthbar.play("3")
		headUI.play("Low")
	elif health == 2:
		healthbar.play("2")
		headUI.play("Low")
	elif health == 1:
		healthbar.play("1")
		headUI.play("Low")

#O2 and O2 Health Bar
func update_o2_bar():
	if o2 >= 100:
		o2 = 100
	for i in range(100):
		var i_timer : int = int(i/4) #Turning 0-100 into 0-25 to change sprites
		if (o2 == i):
			var i_text: String = str(i_timer) # Converts i to String
			o2bar.play(i_text)
	if (o2 <= 0) && (suffocating == false):
		$Timers/suffocate_timer.start()
		suffocating = true
		print(o2)
		print("Suffocating")
	elif (o2 >= 0):
		suffocating = false
		$Timers/suffocate_timer.stop()
		print(o2)
		print("Not Suffocating")

#Jump Handling
func jump():
	$Timers/jump_height_timer.start()
	velocity.y = jump_velocity
	player_sprite.play("ExploJumpStart")
	animation_locked = true
	
#Double Jump Handling
func double_jump():
	velocity.y = double_jump_velocity * 3
	player_sprite.play("ExploJumpLoop")	
	animation_locked = true
	has_double_jumped = true

#Finishing a Jump
func land():
	if(Input.is_action_pressed("shoot")):
		shoot()
	player_sprite.play("ExploJumpEnd")
	animation_locked = true

#Dash Handling
func dash():
	if player_sprite.flip_h == false:
		velocity = dashDirection.normalized() * dash_speed
		velocity.y = 0
		player_sprite.play("ExploDash")
		animation_locked = true
		movement_locked = true
		$Timers/dash_timer.start()
	else:
		velocity = dashDirection.normalized() * dash_speed
		velocity.y = 0
		player_sprite.play("ExploDash")
		animation_locked = true
		movement_locked = true
		$Timers/dash_timer.start()
 
#Jet Fuel Setter
func _set_jetfuel():
	if(jetpack_fuel == 0):
		fuelbar.play("tankEmpty")
	elif(jetpack_fuel == 1):
		fuelbar.play("tankHalf")
	elif(jetpack_fuel == 2):
		fuelbar.play("tankFull")

#Adding Jet Fuel
func add_jetfuel():
	jetpack_fuel = jetpack_fuel + 1
	_set_jetfuel()

#Removing Jet Fuel
func remove_jetfuel():
	jetpack_fuel = jetpack_fuel - 1
	_set_jetfuel()
	check_jetfuel()
	if(jetpack_fuel == 1): 
		$Timers/fuel_timer1.start()
	else:
		$Timers/fuel_timer2.start()
		if($Timers/fuel_timer1.time_left == 0):
			$Timers/fuel_timer1.start()

#Checking Jet Fuel to make sure it doesnt go above it's Maximum
func check_jetfuel():
	if(jetpack_fuel != max_fuel):
		if(jetpack_fuel == 1):
			if ($Timers/fuel_timer1.time_left == 0):
				$Timers/fuel_timer1.start()
			else:
				pass
		elif (jetpack_fuel == 0):
			if($Timers/fuel_timer2.time_left != 0):
				$Timers/fuel_timer2.start()
			else:
				pass
		if(jetpack_fuel > 2):
			jetpack_fuel = 2
			_set_jetfuel()
			
#Shooting
func shoot():
	if can_shoot:
		can_shoot = false
		var instance = bullet.instantiate()
		instance.flip(false)
		instance.dir = rotation
		instance.spawnPos = Vector2(global_position.x - 43 ,global_position.y - 33)
		instance.spawnRot = global_rotation
		if player_sprite.flip_h == true:
			instance.flip(true)
			instance.spawnPos = Vector2(global_position.x - 20,global_position.y - 33)
		main.add_child.call_deferred(instance)
		mag_size -= 1
		check_mag_size(mag_size)

#Checking Magazine Size of the gun
func check_mag_size(mag: int):
	if mag <= 0:
		can_shoot = false
		$Timers/reload_timer.start()
	else:
		$Timers/gun_cooldown.start()

#Animation Lock
func _on_player_sprite_2d_animation_finished() -> void:
	if(["ExploJumpEnd","ExploJumpStart","ExploJumpDouble","ExploDash","Death"].has(player_sprite.animation)):
		animation_locked = false

#Handing the Death Animation
func killPlayer():
	movement_locked = true
	animation_locked = true
	gun_sprite.visible = false
	player_sprite.play("Death")
	$hitbox.monitoring = false
	if has_died == false:
		$Timers/respawn_timer.start()
		has_died = true

#TIMERS BELOW
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

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false
	
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false

func _on_gun_cooldown_timeout() -> void:
	can_shoot = true

func _on_reload_timer_timeout() -> void:
	mag_size = max_mag_size
	can_shoot = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	pass

func _on_hitbox_area_entered(area: Area2D) -> void:
	health -= 1
	update_health_bar()
	gun_sprite.visible = false
	player_sprite.play("HurtRight")

func _on_respawn_timer_timeout() -> void:
	position = %RespawnPoint.position
	$hitbox.monitoring = true
	movement_locked = false
	animation_locked = false
	has_died = false
	health = health_max
	o2 = o2_max
	update_health_bar()

func _on_fall_box_area_entered(area: Area2D) -> void:
	killPlayer()

func _on_o_2_timer_timeout() -> void:
	o2 = o2 - 1
	update_o2_bar()


func _on_suffocate_timer_timeout() -> void:
	health = health - 1
	print(health)
	update_health_bar()
