extends AnimatedSprite2D

@onready var tank_sprite : AnimatedSprite2D = $AnimatedSprite2D

var jetfuel = 2

func _set_jetfuel(new_jetfuel):
	pass

func init_jetfuel(_jetfuel):
	jetfuel = _jetfuel
	tank_sprite.play("tankFull")
