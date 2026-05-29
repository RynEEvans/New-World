extends Area2D

@onready var game_manager = %GameManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		%Player.health += 2
		%Player.update_health_bar()
		queue_free()
