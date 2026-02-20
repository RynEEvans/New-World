extends CharacterBody2D

class_name GulperEnemy

@onready var animated_sprite = $AnimatedSprite2D
@onready var Lray = $LeftCast
@onready var Rray = $RightCast
@onready var for_lunge_hbox = $ForwardLunge

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



func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = 0
	if  (!Lray.is_colliding() || !Rray.is_colliding()) &&  is_on_floor() && !ray_trigger:
		velocity.x = 0
		ray_trigger = true
		$ray_timer.start()
		dir = dir * -1
	move(delta)
	move_and_slide()
	update_facing_direction()

func update_facing_direction():
	if dir.x > 0:
		dir = Vector2(1,0)
		animated_sprite.flip_h = true
		animated_sprite.offset = Vector2(70.0,0)
		for_lunge_hbox.position = Vector2(40.0,0)
	elif dir.x < 0:
		dir = Vector2(-1,0)
		animated_sprite.flip_h = false
		animated_sprite.offset = Vector2.ZERO
		for_lunge_hbox.position = Vector2.ZERO

func move(delta):
	if !motion_locked:
		if !dead:
			if !gulp_is_chase:
				velocity += dir * speed * delta
			is_roaming = true
		elif dead:
			velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func forward_lunge():
	velocity.x = 0
	motion_locked = true
	animated_sprite.play("ForwardLunge")

func _on_direction_timer_timeout() -> void:
	if !motion_locked:
		$direction_timer.wait_time = choose([3.5,4.0,4.5,5.0])
		if (gulp_is_chase == false):
			dir = choose([Vector2.LEFT, Vector2.RIGHT])
			velocity.x = 0
	else:
		motion_locked = false

func _on_ray_timer_timeout() -> void:
	ray_trigger = false

func _on_forward_lunge_body_entered(body: Node2D) -> void:
	print("goteeeeemm")
	forward_lunge()
