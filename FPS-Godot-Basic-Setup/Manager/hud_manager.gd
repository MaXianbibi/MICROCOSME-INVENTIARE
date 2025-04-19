extends Node

@onready var hud : HUD = get_tree().get_first_node_in_group("HUD")

func _ready() -> void:
	assert(hud)
