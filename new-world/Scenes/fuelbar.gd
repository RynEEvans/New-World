extends ProgressBar

@onready var timer = $Timer
@onready var EmptyBar = $EmptyBar

var jetfuel = 2

func _set_jetfuel(new_jetfuel):
	var prev_jetfuel = jetfuel
	jetfuel = min(max_value, new_jetfuel)
	EmptyBar.value = jetfuel
	
	if jetfuel < prev_jetfuel:
		EmptyBar.value = jetfuel
		timer.start()

func init_jetfuel(_jetfuel):
	jetfuel = _jetfuel
	max_value = jetfuel
	value = jetfuel
	EmptyBar.max_value = jetfuel
	EmptyBar.value = jetfuel
