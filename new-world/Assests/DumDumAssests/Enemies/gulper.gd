extends CharacterBody2D

class_name GulperEnemy

@onready var animated_sprite = $AnimatedSprite2D
@onready var Lray = $LeftCast
@onready var Rray = $RightCast
@onready var wall_ray = $wall_detection
@onready var for_lunge_detection = $ForwardLunge
@onready var for_lunge_hitbox = $HeadHitBox/AnimationPlayer
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
var knockback_force = 200
var is_roaming : bool = true
var motion_locked : bool = false
var hit_wall : bool = false
var can_lunge : bool = true
var current_body : Node2D = null



func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = 0
	if  (!Lray.is_colliding() || !Rray.is_colliding()) &&  is_on_floor() && !ray_trigger:
		velocity.x = 0
		ray_trigger = true
		$ray_timer.start()
		dir = dir * -1
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
		animated_sprite.flip_h = true
		animated_sprite.offset = Vector2(70.0,0)
		for_lunge_detection.position = Vector2(35.0,0)
		wall_ray.target_position = Vector2(37,0)
	elif dir.x < 0:
		dir = Vector2(-1,0)
		animated_sprite.flip_h = false
		animated_sprite.offset = Vector2.ZERO
		for_lunge_detection.position = Vector2.ZERO
		wall_ray.target_position = Vector2(-37,0)

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

func forward_lunge(body: Node2D):
	if (can_lunge == true):
		velocity.x = 0
		motion_locked = true
		animated_sprite.play("Charge")
		current_body = body
		$charge_time.start()
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

func _on_forward_lunge_body_entered(body: Node2D) -> void:
	forward_lunge(body)

func _on_head_hit_box_body_entered(body: Node2D) -> void:
	print("goteeeeeem")
	if(current_body == player_node):
		print("KNOCKBACK")
		var knockback_position = Vector2(global_position.x, (global_position.y -25))
		var knockback_direction = (current_body.global_position - knockback_position).normalized()
		current_body.apply_knockback(knockback_direction, 350.0, 0.25)


func _on_charge_time_timeout() -> void:
	animated_sprite.play("ForwardLunge")
	if(animated_sprite.flip_h == false):
		for_lunge_hitbox.play("left_lunge")
	else:
		for_lunge_hitbox.play("right_lunge")
	
	
	$move_timer.start()


func _on_move_timer_timeout() -> void:
	motion_locked = false


func _on_wall_timer_timeout() -> void:
	hit_wall = false


func _on_lunge_cooldown_timeout() -> void:
	can_lunge = true
