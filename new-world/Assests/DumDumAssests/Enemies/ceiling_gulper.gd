extends CharacterBody2D

class_name CeilingGulperEnemy

@onready var animated_sprite = $AnimatedSprite2D
@onready var Lray = $LeftCast
@onready var Rray = $RightCast
@onready var wall_ray = $wall_detection
@onready var l_lunge_direction = $LeftLunge
@onready var lunge_detection = $HeadHitBox/AnimationPlayer
@onready var turn_around = $TurnAround
@onready var u_lunge_detection = $UpLunge
@onready var player_node = %Player
const speed = 30
var gulp_is_chase : bool

var health = 80
var health_max = 80
var health_min = 0

var dead : bool = false
var taking_damage : bool = false
var damage_to_deal = 20
var is_dealing_damage : bool = false
var on_ceiling : bool
var ray_trigger : bool

var dir : Vector2
const gravity = 490
var knockback_force = 500
var is_roaming : bool = true
var motion_locked : bool = false
var hit_wall : bool = false
var can_lunge : bool = true
var current_body : Node2D = null



func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * -1
	if  (!Lray.is_colliding() || !Rray.is_colliding()) &&  is_on_ceiling() && !ray_trigger:
		velocity.x = 0
		ray_trigger = true
		$ray_timer.start()
		dir = dir * -1
	if (is_on_wall()):
		if(hit_wall == false):
			hit_wall = true
			$wall_timer.start()
			dir *= -1

	if (is_on_wall()):
		if(hit_wall == false):
			hit_wall = true
			$wall_timer.start()
			dir *= -1
	move(delta)
	move_and_slide()
	update_facing_direction()

func update_facing_direction():
	if dir.x > 0:
		dir = Vector2(1,0)
		animated_sprite.flip_h = false
		animated_sprite.offset = Vector2.ZERO
		l_lunge_direction.position = Vector2.ZERO
		turn_around.position = Vector2(68,0)
	elif dir.x < 0:
		dir = Vector2(-1,0)
		animated_sprite.flip_h = true
		animated_sprite.offset = Vector2(70.0,0)
		l_lunge_direction.position = Vector2(35.0,0)
		turn_around.position = Vector2.ZERO


func move(delta):
	if !motion_locked:
		if !dead:
			if !gulp_is_chase:
				animated_sprite.play("Idle")
				velocity += dir * speed * delta
			is_roaming = true
		elif dead:
			velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func forward_lunge():
	if (can_lunge == true):
		velocity.x = 0
		motion_locked = true
		animated_sprite.play("Charge")
		$left_charge_time.start()
		$lunge_cooldown.start()

func upward_lunge():
	if (can_lunge == true):
		velocity.x = 0
		motion_locked = true
		animated_sprite.play("Charge")
		$up_charge_time.start()
		$lunge_cooldown.start()

func check_for_wall():
	if (wall_ray.is_colliding()):
		$wall_timer.start()

func _on_direction_timer_timeout() -> void:
	if !motion_locked:
		$direction_timer.wait_time = choose([3.5,4.0,4.5,5.0])
		if (gulp_is_chase == false):
			dir = choose([Vector2.LEFT, Vector2.RIGHT])
			velocity.x = 0

func _on_ray_timer_timeout() -> void:
	ray_trigger = false

func _on_forward_lunge_body_entered() -> void:
	forward_lunge()


func _on_left_charge_time_timeout() -> void:
	animated_sprite.play("ForwardLunge")
	if(animated_sprite.flip_h == false):
		lunge_detection.play("left_lunge")
	else:
		lunge_detection.play("right_lunge")
	
	
	$move_timer.start()


func _on_move_timer_timeout() -> void:
	motion_locked = false


func _on_wall_timer_timeout() -> void:
	hit_wall = false


func _on_lunge_cooldown_timeout() -> void:
	can_lunge = true


func _on_turn_around_body_entered() -> void:
	dir *= -1
	forward_lunge()


func _on_up_lunge_body_entered() -> void:
	upward_lunge()


func _on_up_charge_time_timeout() -> void:
	animated_sprite.offset = Vector2(0,-41)
	animated_sprite.play("UpwardLunge")
	lunge_detection.play("up_lunge")
	
	
	$move_timer.start()
