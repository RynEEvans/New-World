extends PathFollow2D

@onready var sprite : AnimatedSprite2D = $SnapDragon/SnapSprite
@onready var snap_dragon : CharacterBody2D = $SnapDragon

var speed = 0.05
var last_position = global_position
var has_died : bool = false

func _ready() -> void:
	last_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress_ratio += delta * speed
	
	var current_direction = (global_position - last_position).x
	if has_died == false:
		if snap_dragon.health <= 0:
			speed = 0
			has_died = true
		else:
			if current_direction < 0:
				sprite.flip_h = true
			elif current_direction > 0:
				sprite.flip_h = false
	
			last_position = global_position
