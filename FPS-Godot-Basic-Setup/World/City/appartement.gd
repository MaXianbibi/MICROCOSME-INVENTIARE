extends Node
class_name  Appartement

@onready var parent :  Node3D = get_parent()
@export var free_space : int = 12
@export var door : Marker3D = null

func _ready() -> void:
	assert(door)

func get_apparetement_node() -> Node3D:
	return door
