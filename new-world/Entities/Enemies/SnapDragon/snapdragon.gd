extends CharacterBody2D

class_name SnapDragon

@onready var animated_sprite = $SnapSprite
@onready var player_node = %Player
@onready var main = get_tree().get_root().get_node(".")
@onready var fireball = load("res://Entities/Projectiles/Fireball/fireball.tscn")

const speed = 30
var snap_is_chase : bool

var health = 3
var health_max = 3
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
var can_shoot : bool = true
var current_body : Node2D = null
var is_enemy : bool = true
var has_died : bool = false
var animation_locked : bool = false



func _process(delta):
	if (is_on_wall()):
		if(hit_wall == false):
			hit_wall = true
			$Timers/wall_timer.start()
			dir *= -1
	move(delta)
	move_and_slide()
	update_facing_direction()

func update_facing_direction():
	if dir.x > 0:
		dir = Vector2(1,0)
		animated_sprite.flip_h = true
	elif dir.x < 0:
		dir = Vector2(-1,0)
		animated_sprite.flip_h = false

func move(delta):
	if !motion_locked:
		if !dead:
			if !snap_is_chase && !animation_locked:
				animated_sprite.play("Idle")
				velocity += dir * speed * delta
			is_roaming = true
		elif dead:
			velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func shoot(angle_in_radians):
	print(can_shoot)
	if can_shoot:
		can_shoot = false
		animation_locked = true
		animated_sprite.play("Attack")
		$Timers/hit_timer.start()
		var fireball = fireball.instantiate()
		fireball.dir = rotation
		fireball.spawnPos = Vector2(global_position.x - 6 ,global_position.y + 10)
		fireball.spawnRot = angle_in_radians
		fireball.direction = Vector2.RIGHT.rotated(angle_in_radians)
		main.add_child.call_deferred(fireball)
		$Timers/shoot_timer.start()

func _on_ray_timer_timeout() -> void:
	ray_trigger = false

func _on_move_timer_timeout() -> void:
	motion_locked = false


func _on_wall_timer_timeout() -> void:
	hit_wall = false


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func _on_for_diag_body_entered(body: Node2D) -> void:
	print("1")
	if body.name == "Player":
		print("for deteced")
		if animated_sprite.flip_h == true:
			shoot(120)
		else:
			shoot(120)

func _on_down_body_entered(body: Node2D) -> void:
	print("2")
	if body.name == "Player":
		print("down detected")
		shoot(-275)


func _on_back_diag_body_entered(body: Node2D) -> void:
	print("3")
	if body.name == "Player":
		print("back detetced")
		if animated_sprite.flip_h == true:
			shoot(40)
		else:
			shoot(40)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	health -= 1
	print(has_died)
	if health <= 0 && has_died == false:
		has_died = true
		motion_locked = true
		velocity.x = 0
		$Back_Diag.monitoring = false
		$Down.monitoring = false
		$For_Diag.monitoring = false
		$HitBox.monitoring = false
		$HurtBox.monitoring = false
		animated_sprite.play("Death")
		$Timers/respawn_timer.start()
	elif health > 0 && has_died == false:
		print("hit")
		animation_locked = true
		animated_sprite.play("Impact")
		$Timers/hit_timer.start()


func _on_respawn_timer_timeout() -> void:
	queue_free()


func _on_hit_timer_timeout() -> void:
	animation_locked = false
