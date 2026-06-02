extends CharacterBody2D

var fireball_speed : int = 400
var dir : float
var spawnPos : Vector2
var spawnRot : float
var fireball_velocity : Vector2
var zdex : int
var fireball_rotation : int = 90
var direction : Vector2 = Vector2.ZERO
var knockback_force : int = 500

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zdex
	
func _physics_process(delta: float):
	position += direction * fireball_speed * delta
	move_and_slide()

func _on_life_timeout() -> void:
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("HIT")
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("HIT WALL")
	if body.name == "Player":
		body.knockback = position.direction_to(body.position) * knockback_force
	queue_free()
