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

	set_default_mat()
	
func set_default_mat() -> void:
	if mesh_array.is_empty(): return

	for mesh in mesh_array:
		if mesh.material_override: continue
		
		if item_data.world_object_texture:
			mesh.material_override = item_data.world_object_texture
		else:
			mesh.material_override = TextureManager.get_default_material()
			
func set_mat(mat : Material) -> void:
	if mesh_array.is_empty(): return

	for mesh in mesh_array:
		mesh.material_override = mat

	


	
