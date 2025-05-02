extends Node
class_name objectData

@export var item_data : ItemData = null
@onready var parent : PhysicsBody3D = get_parent()

var mesh_array : Array = []

func get_mesh_array() -> Array:
	return parent.find_children("*", "MeshInstance3D", true, false)
	
func _ready() -> void:
	assert(parent)
	assert(item_data)
	
	parent.set_meta("objectData", self)
	mesh_array = get_mesh_array()
	set_texture(item_data.default_texture)
	
func set_texture(texture: Texture2D) -> void:
	if mesh_array.is_empty(): return

	for mesh in mesh_array:
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = texture
		mesh.material_override = mat

	


	
