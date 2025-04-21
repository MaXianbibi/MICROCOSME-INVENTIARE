extends Node
class_name objectData

@export var item_data : ItemData = null
@onready var parent : PhysicsBody3D = get_parent()

func _ready() -> void:
	assert(parent)
	assert(item_data)
	
	parent.set_meta("objectData", self)
	
