extends Node

@onready var player : Player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	assert(player)
