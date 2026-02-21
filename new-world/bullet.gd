extends CharacterBody2D

var bullet_speed : int = 400
var dir : float
var spawnPos : Vector2
var spawnRot : float
var zdex : int

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zdex
	
func _physics_process(delta: float):
	velocity = Vector2(bullet_speed, 0).rotated(dir)
	move_and_slide()

func flip(h : bool):
	if h == true:
		$Sprite2D.flip_h = true
		$Area2D.position = Vector2(-31.818,0)
		if bullet_speed > 0:
			bullet_speed *= -1
	else:
		$Sprite2D.flip_h = false 
		$Area2D.position = Vector2(0,0)
		if bullet_speed < 0:
			bullet_speed *= -1
	


func _on_life_timeout() -> void:
	queue_free()
