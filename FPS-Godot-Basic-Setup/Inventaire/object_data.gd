extends Node
class_name objectData

@export var item_data : ItemData = null
@onready var parent : PhysicsBody3D = get_parent()

var mesh_array : Array = []

var is_placable : bool = true

const COLOR_VALID := Color(0.0, 0.8, 1.0, 0.5)
const COLOR_INVALID := Color(1.0, 0.4, 0.4, 0.3)



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

func set_item_mat() -> void:
	if mesh_array.is_empty(): return
	if item_data.world_object_texture == null: return
	
	for mesh in mesh_array:		
		if item_data.world_object_texture:
			mesh.material_override = item_data.world_object_texture


func change_select_color(can_place: bool) -> void:
	if mesh_array.is_empty():
		return

	if is_placable == can_place:
		return
	
	print("yooo ; )")
	is_placable = can_place
	var color_to_apply: Color = COLOR_VALID if can_place else COLOR_INVALID

	for mesh in mesh_array:
		if mesh is MeshInstance3D:
			var material : Material = mesh.material_override
			if material is ShaderMaterial:
				(material as ShaderMaterial).set_shader_parameter("outline_color", color_to_apply)

	
	
