extends Node3D


@onready var main: Node3D = $Main
var time_scale := 1.0 / 60


func _physics_process(delta: float) -> void:
	main.day_time += delta * time_scale
	if main.day_time >= 23.99:
		main.day_of_year += 1
